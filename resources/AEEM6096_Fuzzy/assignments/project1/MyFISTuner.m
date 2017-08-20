%% This function will take a population consisting of PID gains and measure
function [outfis,fitHist,inds,population] = MyFISTuner(fis,fitness,numIterations,threaded)

% Get some parallel thread workers ready to do some work
if nargin < 4
    threaded = true;
end
if threaded
    pool = parpool(4);
    pctRunOnAll warning('off','all')
end



% Setup some parameters for the genetic algorithm
if nargin < 3
    numIterations = 100;
end
    
[Pin,Pout,Rin,Rout] = fisBreakdown(fis);
inParams = [Pin{:}];
outParams = [Pout{:}];
numInParams = cell2mat(cellfun(@length,inParams,'uni',false));
numOutParams = cell2mat(cellfun(@length,outParams,'uni',false));
numParams = sum([numInParams numOutParams]);
paramRange = [];
paramFlags = [];
for in = 1:length(Pin)
    for inMF = 1:length(Pin{in})
        for inMFp = 1:length(Pin{in}{inMF})
            paramRange = [paramRange;Rin(in,:)];
            if inMFp == 1
                paramFlags = [paramFlags 1];
            elseif inMFp == length(Pin{in}{inMF})
                paramFlags = [paramFlags 3];
            else
                paramFlags = [paramFlags 2];
            end
        end
    end
end
for out = 1:length(Pout)
    for outMF = 1:length(Pout{out})
        for outMFp = 1:length(Pout{out}{outMF})
            paramRange = [paramRange;Rout(out,:)];
            if outMFp == 1
                paramFlags = [paramFlags 1];
            elseif outMFp == length(Pout{out}{outMF})
                paramFlags = [paramFlags 3];
            else
                paramFlags = [paramFlags 2];
            end
        end
    end
end
popSize = 50;
population = zeros(popSize,numParams,numIterations);
individualFitness = zeros(1,popSize);
genFitness = zeros(numIterations,popSize);
iterationMinFitness = zeros(1,numIterations);

% Set population quantities (must sum to popSize)
numElite = 5;   % Elite Children
numRecom = 25;   % Recombination Children
numMut = 12;     % Mutation Children
numRand = 8;    % Randomly Generated Children

if sum([numElite,numRecom,numMut,numRand])~=popSize
    error('There is a mistake with your population set up')
end

% Set number of parents to be picked for recombination
numParents = 17;

%Generate random population within given parameter ranges
for j = 1:popSize
    [Pin,Pout] = fisBreakdown(fisRandomize(fis,2));
    population(j,:,1) = [cell2mat([Pin{:}]) cell2mat([Pout{:}])];
end

%Run simulation for each individual in the population
tic
for generation = 1:numIterations
    fprintf('Generation %d\n',generation);
    if threaded 
        parfor i = 1:popSize
            % Run the simulation and quantify results (or just check the step response of the plant)
            fisTemp = fisReconstruct(fis,population(i,:,generation));
            try
            P = fitness(fisTemp);
%             fprintf('ind%d:S\tP=%0.2f\n',[i,P]);
            catch
%                 population(i,:,generation)
                P = 100;
%                 fprintf('ind%d:F\n',i);
            end
            %Calculate the cost function from the simulation
            individualFitness(i) = P; 
        end
%         fprintf('\n');
    else
        for i = 1:popSize
            % Run the simulation and quantify results (or just check the step response of the plant)
            fisTemp = fisReconstruct(fis,population(i,:,generation));
            %Calculate the cost function from the simulation
            try
                P = fitness(fisTemp);
%                 fprintf('ind%d:S\tP=%0.2f\n',[i,P]);
            catch
                P = 100;
%                 fprintf('ind%d:F\n',i);
            end
            individualFitness(i) = P; 
        end
%         fprintf('\n');
    end
    genFitness(generation,:) = individualFitness;
    iterationMinFitness(generation) = min(individualFitness);
    
    % Select elite children for next generation
    [~,fitIndex] = sort(individualFitness); %sort indivs by fitness and get indices
    eliteChildren = population(fitIndex(1:numElite),:,generation); %the good survive
    parentPool = population(:,:,generation); %
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
    outflag = 0;
    for j = 1:numRecom+numMut
%         fprintf('-----%d-----\n',15 + j);
        randomPick = randperm(numParents);
        parents = parentIndex(randomPick(1:2));
        for k = 1:numParams
            x1x2 = [population(parents(1),k,generation),population(parents(2),k,generation)];
            xMin = min(x1x2);
            xMax = max(x1x2);
            switch paramFlags(k)
                case 1
                    ak = paramRange(k,1);
                    bk = paramRange(k,2);
                case 2
                    ak = recomChildren(j,k-1);
                    bk = paramRange(k,2);
                case 3
                    ak = recomChildren(j,k-1);
                    bk = paramRange(k,2);
            end
            inflag = 0;
            alpha = abs(diff(x1x2))/diff([ak bk]);
            if alpha > 1
                inflag = 1;
                newRange = [ak,bk];
                recomChildren(j,k) = newRange(1) + diff(newRange)*rand;
            else
                I = min([xMin-ak,bk-xMax]);
                newRange = [xMin - I*alpha,xMax + I*alpha];
                if newRange(1) < ak || newRange(2) > bk
                    inflag = 2;
                    newRange(1) = ak;
                    newRange(2) = bk;
                end
                newInterval = diff(newRange);
                recomChildrn(j,k) = newInterval*rand() + newRange(1);
            end
%             fprintf('%d|',k);
%             fprintf('%0.3g|',recomChildren(j,:));
%             fprintf('\n');
%             fprintf('[ak,bk]=[%0.2g,%0.2g]\t',ak,bk);
%             fprintf('newRange=[%0.2g,%0.2g]\t',newRange);
%             fprintf('[xMin,xMax]=[%0.2g,%0.2g]\t\t',xMin,xMax);
%             fprintf('flag:%d\n',inflag);
            if inflag
                outflag = 1;
            end
        end
    end
    if outflag
        warning('Some parameters were impossible.\n All such values were restricted to feasible limits')
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
            switch paramFlags(mutGen(k))
                case 1
                    ak = paramRange(mutGen(k),1);
                    bk = mutChildren(j,mutGen(k)+1);
                case 2
                    ak = mutChildren(j,mutGen(k)-1);
                    bk = mutChildren(j,mutGen(k)+1);
                case 3
                    ak = mutChildren(j,mutGen(k)-1);
                    bk = paramRange(mutGen(k),2);
            end
            if coinFlip(k)
                mutChildren(j,mutGen(k)) = ak+...
                    (recomChildren(j,mutGen(k))-ak)...
                    *(1 - lambdaM(k)*(1-generation/numIterations)^b);
            else
                mutChildren(j,mutGen(k)) = recomChildren(j,mutGen(k))+...
                    (bk-recomChildren(j,mutGen(k)))...
                    *(1 - lambdaM(k)*(1-generation/numIterations)^b);
            end
        end
    end
    
    %Generate random children
    if numRand
        randChildren = zeros(numRand,numParams);
        for j = 1:numRand
            [Pin,Pout] = fisBreakdown(fisRandomize(fis,2));
            randChildren(j,:) = [cell2mat([Pin{:}]) cell2mat([Pout{:}])];
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
        if any(any(isnan(population(:,end,generation+1))))% || 1
            for j = 1:popSize
                row = population(j,:,generation+1);
                if j <= numElite
                    fprintf('%dEL',j);
                elseif j <= numElite + numRecom
                    fprintf('%dRE',j);
                elseif j <= numElite + numRecom + numMut
                    fprintf('%dMU',j);
                else
                    fprintf('%dRA',j);
                end
                fprintf('|');
                for i = 1:numParams
                    fprintf('%0.3g|',row(i))
                end
                fprintf('\n----------------------------------------------------------------\n');
            end
            fprintf('\n-_-_-_-_-_\n')
        end
    end
    bestGenFit = min(genFitness,[],2);
    if generation > 10
        if abs(mean(bestGenFit(generation-10:generation)) - bestGenFit(generation)) < 0.00001 && false
            fprintf('mean(bestGenFit): %f\n',mean(bestGenFit(generation-10:generation)));
            fprintf('bestGenFit(end): %f\n',bestGenFit(generation));
            break
        end
    end
end
toc
if threaded
    delete(pool)
end

[~,loc] = min(genFitness(generation,:));
[~,locs] = min(genFitness(:,:),[],2);
bestFIS = population(loc,:,generation);
outfis = fisReconstruct(fis,bestFIS);
if nargout > 1
    fitHist = min(genFitness(1:generation,:),[],2);
end
if nargout >= 3
    inds = zeros(generation,numParams);
    for gen = 1:generation
        inds(gen,:) = population(locs(gen),:,gen);
    end
end
end