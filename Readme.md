Usage Instructions
==================

The SDK will run on Mac OSX machines only.

Documentation on how to use the OData toolkit for Objective-C can be found in the User Manual under the Doc directory.
     

Directory Structure
====================

	|-- Doc		[Contains OData SDK for Objective-C User Guide]
	|
	|-- framework
	|   |
	|	|
	|	|----- bin
	|		|
	|		|-- ODatagenBinary
	|		|	|
	|		|	|-- odatagen			[Proxy generation tool]
	|		|
	|		|
	|		|-- odatalib
	|			|
	|			|-- lib
	|			|   |
	|			|   |-- iPhoneDeviceLibs	[OData toolkit static library built for different device SDK versions]
	|		    |   |
	|			|   |
	|			|   |-- iPhoneSimulatorLibs	[OData toolkit static library built for different simulator SDK versions]
	|			|
	|			|
	|			|
	|			|-- include
	|				|
	|				|-- Azure       	[contains files for using OData toolkit library against Windows Azure tables]
	|  				|
	|			        |-- Common      	[contains commonly used class definition files for dictionary, collection, 
	|        			|			 guid, http proxy, reflection helper.Utility classes for Azure ACS and Azure
	|        			|               	 Table authentication and xsl file for code generation]
	|        			|
	|			        |-- Context     	[Contains class definition files for context tracking, AtomPub generation,
	|			        |               	  query and stream processing files]
	|			        |
	|				|-- Credential  	[Contains class definition files for credentials]
	|				|
	|			        |-- Exception  		[Contains class definition files for exceptions]
	|        			|
	|			        |-- Interfaces  	[Interface definitions]
	|			        |
	|			        |-- Parser     		[AtomPub parser]
	|        			|
	|			        |-- WebUtil     	[Utility files for handling normal and batch http request-response]
	|
	|
	|-- Sample	[Contains sample iPhone application]
	|	|
	|	|----- DataMarket					[NEW: Azure datamarket sample program]
	|	|
	|	|----- Netflix						[Netflix sample program]
	|	|
	|	|----- OData.org					[Sample client for OData website demo producers]
	|	
	|-- Readme.txt	[This file, one which is being read, contains files and directory information]
	|
	|-- License.txt	[Contains license information]
