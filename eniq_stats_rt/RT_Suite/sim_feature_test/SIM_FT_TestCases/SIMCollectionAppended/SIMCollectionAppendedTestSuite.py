'''
Created on 5 Oct 2015

@author: ecalmcg
'''

import subprocess
import logging
import sys
import datetime
import os
from time import sleep



class SIMCollectionAppendedTestSuite(object):
    '''
    Description: Reactive TestCases appended
    '''
    secondRopAppendedLastLine = ''
    fileName = ''
    destDirSizePreMaxCheckTestCase = 0
    
  
    
    def bFirstRopNonCollect(self, nodeName, protocolName, destDir, numberOfProtocolsInEntireTest):
        print 'Appended '+ str(protocolName) + ' - Thread waiting until first ROP has happened and log file is updated \n'
               
        current_time = datetime.datetime.now().time()
        minute = current_time.minute
        flag = True
        bpr=subprocess.Popen(['/eniq/sw/platform/sim-*/sim_feature_test/scripts/./updateAppendedFiles.sh'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        out=bpr.communicate()
        print str(out)
        
        
        
        
        
        while flag:
            current_time = datetime.datetime.now().time()
            minute = current_time.minute
            if minute == 02: 
                flag = False
            
            int(minute)
            sleep(30)
        
        
        
        print 'Checking ' + destDir + ' to ensure no files collected from ' + protocolName + '\n'
        
        files = []
        files = os.listdir(destDir)
        
        if len(files) > 0:
            print 'Failed - There should be 0 files in the interface directory after the first ROP'
            return False
        print 'Passed - Appended First ROP non collect ' + protocolName + '\n'
        return True
    
        
    def cSecondRopCollect(self, nodeName, protocolName, destDir, numberOfProtocolsInEntireTest):
        print 'Appended '+ protocolName + ' - Thread waiting for collection of appended file in second rop collection \n'
        
        bpr=subprocess.Popen(['/eniq/sw/platform/sim-*/sim_feature_test/scripts/./updateAppendedFiles.sh'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        out=bpr.communicate()
        print str(out)
        
        sleep(60 * 15)
        
        '''
        files = []
        files = os.listdir(destDir)
        size = len(files)
               
        if size == 0:
            print 'Appended '+ protocolName +' Error, no files were collected \n'
            return False
        
        else:
            try:
                f =  open(destDir+'/'+files[0], 'r')
            except Exception:    
                print 'EXCEPTION - Directory is empty '+ destDir
                
            for line in f:
                pass
            SIMCollectionAppendedTestSuite.secondRopAppendedLastLine = line
            
        print 'Passed - ' + str(protocolName) + ' - Collected second ROP \n'    
        return True
        '''
    
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
            if signal in sentences[index] and 'Successfully collected' in sentences[index]:
                logPassed = True
        
        return logPassed        
                
    
    def dOnlyNewUpdatedCollect(self, nodeName, protocolName, destDir, numberOfProtocolsInEntireTest):
        print 'Appended '+ str(protocolName) + ' - Thread waiting for 3rd rop collection. \n  Checking is updated file contain only new entries \n'
        bpr=subprocess.Popen(['/eniq/sw/platform/sim-*/sim_feature_test/scripts/./updateAppendedFiles.sh'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        out=bpr.communicate()
        print str(out)
        
        sleep(60*15)
        
        files = os.listdir(destDir)
        SIMCollectionAppendedTestSuite.destDirSizePreMaxCheckTestCase = len(files)
        

        try:
            f =  open(destDir+'/'+files[0], 'r')
        except Exception:
            print 'EXCEPTION - Directory must be empty ' + destDir + ' Should not be empty'
            print 'Only new updated data collected failed due to no files present in interface directory'
            return False
            
        'SIMCollectionAppendedTestSuite.destDirSizePreMaxCheckTestCase'
        duplicatedCount = 0;
        
        for line in f:
            if line == SIMCollectionAppendedTestSuite.secondRopAppendedLastLine:
                duplicatedCount+=1
        
        if duplicatedCount >1:
            print 'Duplicated line, test failed \n'
            return False  
              
        print 'Passed - Only new data has been collected ' + str(protocolName)
        return True

    
    def eMaxFilesCollected(self, nodeName, protocolName, destDir, numberOfProtocolsInEntireTest):
        print 'Appended '+ str(protocolName) + ' - Thread waiting for 4th rop collection, Placing > 30 files in collection directory. No updates \n'
        
        bpr=subprocess.Popen(['/eniq/sw/platform/sim-*/sim_feature_test/scripts/./maxAppendedFiles.sh'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        out=bpr.communicate()
        print str(out)
        
        bpr=subprocess.Popen(['/eniq/sw/platform/sim-*/sim_feature_test/scripts/./updateAppendedFiles.sh'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        out=bpr.communicate()
        
        sleep(60 * 15)
        
        files = []
        files = os.listdir(destDir)
        size = len(files) 
        'maxPossibleSize = SIMCollectionAppendedTestSuite.destDirSizePreMaxCheckTestCase + 30'
        
        if size - SIMCollectionAppendedTestSuite.destDirSizePreMaxCheckTestCase < 50:
            print protocolName + '- Not enough files collected to test. Now = ' + str(size) + ' Before = '+str(SIMCollectionAppendedTestSuite.destDirSizePreMaxCheckTestCase) + ' : Technically passed \n'
            return True
        elif size - SIMCollectionAppendedTestSuite.destDirSizePreMaxCheckTestCase > 50:
            print protocolName + '- Test failed as more files than 50 must have been collected \n'
            return False
        else:
            print protocolName + 'Passed - Max files collected for \n'
            return True
 
        
    def fStopCollectAfterFourRopsOfNoNewData(self, nodeName, protocolName, destDir, numberOfProtocolsInEntireTest):
        print 'Appended '+ str(protocolName) + ' -  Thread waiting on the 5th, 6th, 7th, 8th ROP with no new data appended to file for all rops \n Checking log for non collection line \n'
        
        sleep(60*76)
        
        print 'Thread starting again to check Stops collections after no update for four ROPs of no new data \n'
        
        listOfNoCollection=[]
        
        bpr = subprocess.Popen(['cat /eniq/log/sw_log/sim/sim.log'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        out = bpr.communicate()
        
        sentences = str(out).rstrip().split('\\n')
      
        
        for s in sentences:
            if 'unchanged for 4 ROPs and will no longer be collected' in s:
                print 'Passed - Stops collecting after 4 ROPS of no modification ' + str(protocolName)
                return True
        
      
      
        
        print 'Failed - Stops collections after no update for four ROPs of no new data \n '
        return False
    
    
