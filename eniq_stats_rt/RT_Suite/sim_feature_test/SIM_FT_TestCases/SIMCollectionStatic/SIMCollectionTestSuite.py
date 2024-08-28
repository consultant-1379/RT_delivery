
'''
Created on Aug 27, 2015

@author: Calvin
'''
import subprocess
import datetime
import os
import re
import glob
import types
from time import sleep
from javapath import join






class SIMCollectionTestSuite(object):
    '''
    Description: Reactive TestCases static
    '''
    

    lastSentenceInLog = ''
    totalFilesRecordedOfPluginSecondROP = []
    ropTime = 0
    secondROPFileCounts={}
    
        
    
    def firstRopNonCollect(self, nodeName, protocolName, destDir, numberOfProtocolsInEntireTest):
        print 'Static '+ str(protocolName) + ' - Thread waiting until first ROP has happened and log file is updated \n'
      
             
        current_time = datetime.datetime.now().time()
        minute = current_time.minute
        hour = current_time.hour
       
       
        while minute != 02:
            sleep(30)
            current_time = datetime.datetime.now().time()
            minute = current_time.minute
        
           
            
        if 'MINSAT' in protocolName:
            
            if hour%2 == 0:
                print 'MINSAT - Wait to next even hour for first ROP  \n'
                sleep(60*60)
                'By the time this gets executed only 1 non collect line will be in the log so we update the comparison total'
               
                print 'First ROP for MINSAT nodes, wait on updated log \n'
            
            else:
                print 'First ROP for MINSAT nodes, wait on updated log \n'
        
        elif 'SDP' in protocolName:  
            print 'First ROP for SDP Plugin starting again \n'
        
        else:
            print 'Static '+ str(protocolName) + ' - First ROP has happened, wait on log file is updated \n'
        
       
        bpr = subprocess.Popen(['cat /eniq/log/sw_log/sim/sim.log;'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        stdout_value = bpr.communicate()
        sentences = str(stdout_value).rstrip().split('\\n')
       
        'Log Checking'
        logLine = 'ROP: '+str(nodeName)+' - '+str(protocolName)
        logPassed = False
        signal=''
        searchFromIndex=0
        words=[]
          
        for l in range(0, len(sentences) - 1, 1):
            if logLine in sentences[l]:
                words = sentences[l].rstrip().split()
                signal = words[2]

                searchFromIndex=l+1
                break
        
        for index in range(searchFromIndex, len(sentences), 1):     
            if signal in sentences[index] and 'SIM first rop. No files were collected' in sentences[index]:
                logPassed = True
        
    
        print 'Checking ' + destDir + ' to ensure no files collected from ' + protocolName + '\n'
        
        files = []
        files = os.listdir(destDir)
        
        if len(files) > 0:
            print 'Failed - There should be 0 files in the interface directory after the first ROP'
            return False
        elif logPassed == False:
            print 'SIM functions but log not correct'
            return True
        else:
            print 'Passed - First ROP non collect ' + protocolName + '\n'
            return True
    
    
    def secondRopCollect(self, nodeName, protocolName, destDir, numberOfProtocolsInEntireTest):
        print 'Static '+ str(protocolName) + ' - Thread waiting on log to be updated to ensure files are collected on the second ROP \n'
        
        
       
        'Only run this script one time'
        if protocolName == 'IVR_Plugin':
            bpr=subprocess.Popen(['/eniq/sw/platform/sim-*/sim_feature_test/scripts/./preSecondROP.sh'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
            out=bpr.communicate()
            print str(out)
        
        if 'MINSAT' in protocolName:
            print 'Thread sleeping for 2 hours, MINSAT plugin \n'
            sleep(60*120)
            print 'Thread for MINSAT nodes starting again \n'
        elif 'SDP' in protocolName:
            print 'Sleeping one hour, SDP plugin \n'
            sleep(60*60)
            print 'Thread for SDP nodes starting again \n' 
        else:
            print 'Thread waiting 15 minutes until second ROP \n'
            sleep(60 * 15)
            
        
        if protocolName == 'CCNDiam_Plugin':
            regEx = '*Diameter*'
            mutlipleProtocolsSameDestination = True
        elif protocolName == 'CCNPLAT_Plugin':
            regEx = '*PlatformMeasures'
            mutlipleProtocolsSameDestination = True
        elif protocolName == 'CCNOAM_Plugin':
            regEx = '*OAM*'
            mutlipleProtocolsSameDestination = True
        else:
            mutlipleProtocolsSameDestination = False
                   
      
        listOfPlugInFilesInDestDir = []
        
        if mutlipleProtocolsSameDestination:      
            for f in glob.glob1(destDir, regEx):
                listOfPlugInFilesInDestDir.append(f)
        
        else:
            listOfPlugInFilesInDestDir = os.listdir(destDir)
        
        
            
        SIMCollectionTestSuite.secondROPFileCounts[protocolName] = len(listOfPlugInFilesInDestDir)  
        SIMCollectionTestSuite.totalFilesRecordedOfPluginSecondROP = len(listOfPlugInFilesInDestDir)

                      
            
        bpr = subprocess.Popen(['cat /eniq/log/sw_log/sim/sim.log'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        stdout_value = bpr.communicate()
        out=stdout_value
        sentences = str(stdout_value).rstrip().split('\\n')
       
        
        logLine = 'ROP: '+str(nodeName)+' - '+str(protocolName)
        
        signal=''
        searchFromIndex=0
        words=[]
          
        for l in range(0, len(sentences) - 1, 1):
            if logLine in sentences[l]:
                words = sentences[l].rstrip().split()
                signal = words[2]

                searchFromIndex=l+1
                break
        
        for index in range(searchFromIndex, len(sentences), 1):
            
            if signal in sentences[index] and 'Successfully collected' in sentences[index]:
                
                if len(listOfPlugInFilesInDestDir) > 0:
                    print 'Passed - '+protocolName +' successfully collected second ROP ' +str(len(listOfPlugInFilesInDestDir)) + ' files collected \n'
                    return True
                else:
                    print protocolName + 'Cannot confirm test. SIM logged the attempted collection but files were never mediated. Are files present to collect'
                    return False
            
        print 'Failed - '+protocolName +' collecting the second ROP \n'        
        return False
        
    
    def xMaxFilesCollectedEachROP(self, nodeName, protocolName, destDir, numberOfProtocolsInEntireTest):
        print 'Static '+ str(protocolName) + ' - Thread waiting on the third ROP Collection ensuring only max of 30 are collected \n'
        
        
        'Only run this script one time'
        if protocolName == 'IVR_Plugin':
            bpr=subprocess.Popen(['/eniq/sw/platform/sim-*/sim_feature_test/scripts/./preThirdROP.sh'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
            out=bpr.communicate()
            print str(out)
            
        if protocolName == 'SDP_Plugin':
            bpr=subprocess.Popen(['/eniq/sw/platform/sim-*/sim_feature_test/scripts/./preSDPThirdROP.sh'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
            out=bpr.communicate()
            print str(out)
          
        if protocolName == 'MINSATss_Plugin':
            bpr=subprocess.Popen(['/eniq/sw/platform/sim-*/sim_feature_test/scripts/./preMinsatThirdROP.sh'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
            out=bpr.communicate()
            print str(out)
        
        
        if 'MINSAT' in protocolName:
            print 'MINSAT Thread waiting 2 hrs until next ROP \n'
            sleep(60*120)
        elif 'SDP' in protocolName:
            print 'SDP Thread Sleeping one hour until next ROP'
            sleep(60*60)
        else:
            print 'Thread waiting  15 minutes until next ROP \n'
            sleep(60 * 16)
        
        if protocolName == 'CCNDiam_Plugin':
            regEx = '*Diameter*'
            mutlipleProtocolsSameDestination = True
        elif protocolName == 'CCNPLAT_Plugin':
            regEx = '*PlatformMeasures'
            mutlipleProtocolsSameDestination = True
        elif protocolName == 'CCNOAM_Plugin':
            regEx = '*OAM*'
            mutlipleProtocolsSameDestination = True
        else:
            mutlipleProtocolsSameDestination = False
        
        
        listOfPlugInFilesInDestDirThirdROP = []
      
        
        if mutlipleProtocolsSameDestination:
            for f in glob.glob1(destDir, regEx):
                listOfPlugInFilesInDestDirThirdROP.append(f)
        else:
            listOfPlugInFilesInDestDirThirdROP = os.listdir(destDir)
       

        ThirdROPFileCount = len(listOfPlugInFilesInDestDirThirdROP)
        secondROPFileCount = SIMCollectionTestSuite.secondROPFileCounts.get(protocolName)
        
       
        if ThirdROPFileCount - secondROPFileCount == 50:
            print 'Passed - Max file collection test case for ' +str(protocolName)
            return True
        elif ThirdROPFileCount - secondROPFileCount < 50:
            print 'Not enough files ('+str(ThirdROPFileCount-secondROPFileCount)+') created to test the maximum test case for: ' + str(protocolName) +' (' +str(ThirdROPFileCount)+')('+str(secondROPFileCount)+') \n'
            return True
        else:
            print 'Max files collected failed '+ str(ThirdROPFileCount) + ' is the 3rd count for '+ str(protocolName) + ' and 2nd is ' + str(secondROPFileCount)
            return False
    
    
    def zOnlyNewFilesCollected(self, nodeName, protocolName, destDir, numberOfProtocolsInEntireTest):
        print 'Static '+ str(protocolName) + ' - Comparing the second and third ROP collection ensuring only new files have been collected \n'
        
        
        if protocolName == 'CCNDiam_Plugin':
            regEx = '*Diameter*'
            mutlipleProtocolsSameDestination = True
        elif protocolName == 'CCNPLAT_Plugin':
            regEx = '*PlatformMeasures'
            mutlipleProtocolsSameDestination = True
        elif protocolName == 'CCNOAM_Plugin':
            regEx = '*OAM*'
            mutlipleProtocolsSameDestination = True
        else:
            mutlipleProtocolsSameDestination = False
        
        
        files = []
       
        
        if  mutlipleProtocolsSameDestination:
            for f in glob.glob1(destDir, regEx):
                files.append(f)
        else:
            files = os.listdir(destDir)
        
        
        
        for i in range(0 , len(files) - 1, 1):
            f = files[i]
        
            for j in range(0, len(files) - 1, 1):
                ff = files[j]
                if i == j:
                    continue
                elif(str(f) == str(ff)):
                    print 'Failed - Same file has been collected again \n'
                    return False
                
        print 'Passed - Only new files have been collected for '+ str(protocolName)            
        return True  
    
    
    
   
    
