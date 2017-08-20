import cv2
import numpy as np
import os

imlist = [im for im in os.listdir(os.getcwd()) if 'image1' in im]

def detect_target(data):
	fy = 533.98
	hsv = cv2.cvtColor(data,cv2.COLOR_BGR2HSV)
	yel_lo = (20,100,100)
	yel_hi = (30,255,255)
	mask = cv2.inRange(hsv,yel_lo,yel_hi)
	cnts = cv2.findContours(mask,1,2)[0]
	if not len(cnts):
		return data,None,None,None
	target = sorted(cnts,key=lambda c:cv2.contourArea(c))[-1]
	ellipse_rect = cv2.fitEllipse(target)
	area = cv2.contourArea(target)
	diam = np.sqrt(4*area/np.pi)
	dist = 0.255*2*fy/diam
	dz = dist
	print(dz,diam)
	M = cv2.moments(target)
	if not M["m00"]:
		return mask,None, None,None
	ct = ((M["m10"]/M["m00"]),(M["m01"]/M["m00"]))
	ci = ((data.shape[0]/2),(data.shape[1]/2))
	heading = (ct[0]-ci[0],ci[1]-ct[1])
	dx = dz*np.tan(np.arctan(heading[0]/fy))
	dy = dz*np.tan(np.arctan(heading[1]/fy))
	return mask,heading,ct,ci

def output_im(imfile):
	im = cv2.imread(imfile)
	mask,heading,ct,ci = detect_target(im)
	if heading is None:
		cv2.imwrite(imfile[:-4]+'_proc.png',im)
	else:
		im = cv2.bitwise_and(im,im,mask=mask)
		imline = cv2.line(im,(int(ci[0]),int(ci[1])),(int(ct[0]),int(ct[1])),(0,0,255))
		cv2.imwrite(imfile[:-4]+'_proc.png',im)

for im in imlist:
	output_im(im)
