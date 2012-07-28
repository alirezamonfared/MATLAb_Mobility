clear all
%javaaddpath('/home/alireza/workspace/MobilityProject/Java/EvolvingGraphs/EV.jar');
javaaddpath('/home/alireza/workspace/MobilityProject/Java/EvolvingGraphs/EvolvingGraphs/bin');
%javaaddpath('/home/alireza/workspace/MobilityProject/Java/EvolvingGraphs/EvolvingGraphs/bin/br/usp/ime/graphreport')
%p = genpath('/home/alireza/workspace/MobilityProject/Java/EvolvingGraphs/EvolvingGraphs/bin');
%p =regexp(p,':','split');
%for pth = p
%    javaaddpath(p);
%end

%import static org.junit.Assert.fail;
% import br.usp.ime.evolvinggraph.EvolvingGraph;
% import br.usp.ime.graphreader.ONEGraphReader;
% import br.usp.ime.graphreport.GraphReporter;

reporter = javaObject('br.usp.ime.graphreport.TestReportsAlireza');
args = javaArray('java.lang.String',4);
MainArgs = javaArray('java.lang.String',2);
%args(1) = java.lang.String(...
%    '/home/alireza/workspace/MobilityProject/MATLAB/Sampling/Results/CSV4OriginalSampled20phi.one');
args(1) = java.lang.String(...
    '/home/alireza/workspace/MobilityProject/MATLAB/Sampling/Results/CSV4OriginalLinks.one');
args(2) = java.lang.String(...
    '/home/alireza/workspace/MobilityProject/MATLAB/Sampling/Results/Res.txt');
args(3) = java.lang.String('50');
args(4) = java.lang.String('999');
MainArgs(1) = args(1);
MainArgs(2) = args(2);


Res = javaMethod('TestJourneyUnreachableReport', reporter, args);
%javaMethod('main', reporter, MainArgs);


%reporter = javaObjectEDT('MasterTestAlireza');
%reporter.main('../../../MATLAB/Sampling/Results/CSV4OriginalJSampled20phi.one', '../../../MATLAB/Sampling/Results/Res.txt');
%javaMethodEDT('main','br.usp.ime.graphreport.TestReportsAlireza','../../../MATLAB/Sampling/Results/CSV4OriginalJSampled20phi.one', '../../../MATLAB/Sampling/Results/Res.txt');
%reporter.testReadONEFile()

%javaMethodEDT('main','MasterTestAlireza');
 


%% BLK 1

% reporter = javaObject('br.usp.ime.graphreport.GraphReporter');
% str = java.lang.String(...
%     '/home/alireza/workspace/MobilityProject/MATLAB/Sampling/Results/CSV4OriginalSampled20phi.one');
% reader = javaObject('br.usp.ime.graphreader.ONEGraphReader',...
%     str,51,1000);
% try
%     reporter.readGraph (reader);
%     disp('Reporter Done')
%     %reporter.journeyUnreachableReport();
%     javaMethod('journeyUnreachableReport',reporter);
% catch ME
%     error('Max Time Not init')
% end


%%

% GraphReporter reporter = new GraphReporter ();
% 		ONEGraphReader reader = new ONEGraphReader("../../../MATLAB/Sampling/Results/CSV4OriginalLinks.one",51,1000);		
% 		EvolvingGraph gp = new EvolvingGraph();
% 		double[] Result;
% 		try {			
% 			reporter.readGraph (reader);
% 			//Result = reporter.journeyTimeReport();
% 			Result = reporter.journeyUnreachableReport();
% 			for(int i=0; i<Result.length;i++)
% 				System.out.println(Result[i]);
% 		} catch (Exception e) {
% 			fail("MaxTime not initialized2.");
% 		}
% 		gp = reporter.getGraph();	
% 		System.out.print(gp.getNumOfNodes());
% 		System.out.print("\n");
