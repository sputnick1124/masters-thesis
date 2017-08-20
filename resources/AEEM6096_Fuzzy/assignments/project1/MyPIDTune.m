%% This function will take a population consisting of PID gains and measure
% the step response or the performance of the PID compensator as its
% measure of fitness. Well-performing gains will be selected as progenitors
% of future PID children. They will be recombined together to make better
% gains and the process will be repeated until sufficient control of the
% situation is attained.

% Get some starting values for KP, KI, and KD by RL methods

function [KP,KI,KD] = MyPIDTune(Gp,fitness,PID)

% Get some parallel thread workers ready to do some work

pool = parpool(4);
pctRunOnAll warning('off','all')

% Setup some parameters for the genetic algorithm
numIterations = 20;
numParams = 3;
popSize = 100;
population = zeros(popSize,numParams,numIterations);
paramRange = [zeros(3,1) 150*de2bi(PID,3)'];
individualFitness = zeros(1,popSize);
genFitness = zeros(numIterations,popSize);
iterationMinFitness = zeros(1,numIterations);

% Set population quantities (must sum to popSize)
numElite = 15;   % Elite Children
numRecom = 50;   % Recombination Children
numMut = 25;     % Mutation Children
numRand = 10;    % Randomly Generated Children

if sum([numElite,numRecom,numMut,numRand])~=popSize
    error('There is a mistake with your population set up')
end

% Set number of parents to be picked for recombination
numParents = 20;

%Generate random population within given parameter ranges
for i = 1:numParams
    range = paramRange(i,2)-paramRange(i,1);
    for j = 1:popSize
        population(j,i,1) =  range.*rand(1) + paramRange(i,1);
    end
end

%Run simulation for each individual in the population
tic
for generation = 1:numIterations
    fprintf('Generation %d\n',generation);
    
    % Slice population to minimize communication overhead in for loop
    KDs = population(:,1,generation);      %Parameter 1
    KPs = population(:,2,generation);      %Parameter 2
    KIs = population(:,3,generation);      %Parameter 3  
%     parfor i = 1:popSize
    parfor i = 1:popSize
        %Run the simulation for this individual
        KD = KDs(i);
        KP = KPs(i);
        KI = KIs(i);
        
        % Run the simulation and quantify results (or just check the step response of the plant)
%         Gc = tf([KD KP KI],[1 0]);
%         sys = feedback(Gc*Gp,1);
        P = fitness(Gp,[KP,KI,KD]);
        %Calculate the cost function from the simulation
        individualFitness(i) = P; 
    end
    genFitness(generation,:) = individualFitness;
    iterationMinFitness(generation) = min(individualFitness);
    
    % Select elite children for next generation
    [v,fitIndex] = sort(individualFitness);
    eliteChildren = population(fitIndex(1:numElite),:,generation);
    parentPool = population(:,:,generation);
    parentPool(fitIndex(1:numElite),:) = [];
    
    % Select parents to compete
    individualFitness(fitIndex(1:numElite)) = [];
    fitnessValues = individualFitness;
    parentIndex= zeros(1,numParents);

    % Select parents by group tournaments
    K = 3;
    for j = 1:numParents-numElite
        randomPick = randperm(popSize-numElite-j+1);
        contestants = randomPick(1:K);
        parentIndex(j) = find(individualFitness == min(fitnessValues(contestants)), 1 );
        % Remove selection from population
        fitnessValues(find(fitnessValues==individualFitness(parentIndex(j)),1)) = [];
    end
    % Add elite children into the parent pool
    parentIndex(j+1:end) = fitIndex(1:numElite);
   
    recomChildren = zeros(numRecom+numMut,numParams);
    %%% Modified BLX-alpha crossover recombination
    for j = 1:numRecom+numMut
        randomPick3 = randperm(numParents);
        parents = parentIndex(randomPick3(1:2));
        for k = 1:numParams
            x1x2 = [population(parents(1),k,generation),population(parents(2),k,generation)];
            xMin = min(x1x2);
            xMax = max(x1x2);
            ak = paramRange(k,1);
            bk = paramRange(k,2);
            alpha = abs(diff(x1x2))/diff(paramRange(k,:));
            I = min([xMin-ak,bk-xMax]);
            newRange = [xMin - I*alpha,xMax + I*alpha];
            flag = 0;
            if newRange(1)<ak
                flag = 1;
                newRange(1) = ak;
            end
            if  newRange(2)>bk
                flag = 1;
                newRange(2) = bk;
            end
            newInterval = diff(newRange);
            recomChildren(j,k) = newInterval*rand() + newRange(1);
        end
    end
    if flag
        warning('Some parameters were out of specified ranges.\n All such values were restricted to range limits')
    end

    % Non-uniform mutation of children
    mutChildren = recomChildren(1:numMut,:);
    numGen = 2;  % Number of genetic components to mutate within each gene
    b = 1.5;  % Arbitrary exponent to drive late-generation mutations to 0
    for j = 1:numMut
        coinFlip = round(rand(1,numGen));
        lambdaM = rand(1,numGen);
        randomPickM = randperm(numParams);
        mutGen = randomPickM(1:numGen);
        for k = 1:numGen
            if coinFlip(k)
                mutChildren(j,mutGen(k)) = paramRange(mutGen(k),1)+...
                    (recomChildren(j,mutGen(k))-paramRange(mutGen(k),1))...
                    *(1-lambdaM(k)*(1-generation/numIterations)^b);
            else
                mutChildren(j,mutGen(k)) = paramRange(mutGen(k),2)-...
                    (paramRange(mutGen(k),2)-recomChildren(j,mutGen(k)))...
                    *(1-lambdaM(k)*(1-generation/numIterations)^b);
            end
        end
    end
    
    %Generate random children
    if numRand
        randChildren = zeros(numRand,numParams);
        for i = 1:numParams
            range = paramRange(i,2)-paramRange(i,1);
            for j = 1:numRand
                randChildren(j,i) =  range.*rand(1) + paramRange(i,1);
            end
        end
    end

    % Build next generation
    sumChildren = sum([numRecom,numElite,numMut]);
    if generation<numIterations
        population(1:sumChildren,:,generation+1) = [eliteChildren;
            recomChildren(numMut+1:end,:);
            mutChildren];
        if numRand
            population(sumChildren+1:end,:,generation+1) = randChildren;
        end
    end
end
toc
delete(pool)

[~,loc] = min(genFitness(end,:));
bestGains = population(loc,:,end);
KD = bestGains(1); KP = bestGains(2); KI = bestGains(3);
Gco = tf(bestGains,[1 0]);
syso = feedback(Gco*Gp,1);
figure()
step(syso)
end