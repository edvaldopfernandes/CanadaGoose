/*******************************************************************************************************************************
 * @Name         RestServiceToInsertOrderAndOthers
 * @Author       Venkata Kalyan
 * @Date         08/02/2024
 * @Description  Rest Web Service To order and others
 *******************************************************************************************************************************
 * Version      Developer                Date          Description
 *-------------------------------------------------------------------------------------------------------------------------------
 *  1.0       Venkata Kalyan        08/02/2024   Initial Creation
 ********************************************************************************************************************************/
@RestResource(urlMapping='/restWebServiceToInsertPOSOrders/')
global without sharing class RestWebServiceToInsertPOSOrders {

    @HttpPost
    global static void doPost() {
        String message = '';
        String response ='';
        string xmlString ='';
        String jsonString ='';
        try {
                RestRequest req = RestContext.request;
            	//jsonString = req.requestBody.toString();
            	system.debug('XML String---'+req.requestBody.toString());
            	xmlString = req.requestBody.toString();
            	jsonString = updateData(req.requestBody.toString());
                Blob body = req.requestBody;
                  	
        }catch (Exception ex) {
            	System.debug(message +'>>>Catch Exception' +ex);
            	IntegrationLogUtility.error = ex.getMessage();
            if(jsonString != null){
            	IntegrationLogUtility.status = 'Request captured With Error';
            }else {
                IntegrationLogUtility.status = 'Empty Request';
            }
            	IntegrationLogUtility.exp = ex;
        }
        finally{
             string resCode = '';
           		RestResponse res = RestContext.response;
                if(xmlString != '' && xmlString != NULL){
                    res.responseBody = Blob.ValueOf(response);
                    res.statusCode = 200;
                    resCode = response;
                    if(String.valueOf(response) == '[]'){
                        resCode = 'Insertion failed due to internal error';
                        IntegrationLogUtility.status = 'Request captured With Error';
					}
                }
            	else{ res.statusCode = 400;  resCode = 'failure';}
            	IntegrationLogUtility.createOutBoundLog(xmlString, resCode , 'restService_Order'+DateTime.now(), 'Inbound', 'restService_Order', null);
         }
    }
    
    public static string updateData(string xmlReq){
       	Dom.Document doc = new Dom.Document();
        doc.load(xmlReq);
        Dom.XMLNode root = doc.getRootElement();  //getting the root element and parsing it recursively
        Object temp = parse(root);
        Map<String, Object> jsonResult = new Map<String, Object>{root.getName() => temp};
        system.debug('>>>>>jsonResult>>>'+JSON.serialize(jsonResult));
        return JSON.serialize(jsonResult);
    }
    
    //method to recursively parse child nodes from XML document
    private static Object parse(Dom.XMLNode node){
       	Map<String, Object> jsonResult = new Map<String, Object>();  //map to store data of current XML node
        List<Dom.XMLNode> children = node.getChildElements(); //getting list of child elements
        if(children.isEmpty()){
            return node.getText(); //if no child elements found, we simply return the text value
        }
		Map<String, Integer> nodeNameCount = new Map<String, Integer>(); //map to store occurence count of child elements against their names
        for(Dom.XMLNode child : children){
            String nodeName = child.getName();
            if(!nodeNameCount.containsKey(child.getName())){
                nodeNameCount.put(nodeName, 0);
            }
			Integer oldCount = nodeNameCount.get(nodeName);
            nodeNameCount.put(nodeName, oldCount + 1);
        }
        for(Dom.XMLNode child : children) {  //iterating over child elements and parsing them recursively
        	Object temp = parse(child);
            String nodeName = child.getName();
            //checking if this child is an array 
            Boolean childIsArray = (nodeNameCount.get(nodeName) > 1);
            if(childIsArray) {  //if child is array, save the values as array, else as strings. 
                if(jsonResult.get(nodeName) == null){
                    jsonResult.put(nodeName, new List<Object>{ temp });
                }
                else{
                    List<Object> tempList = (List<Object>)jsonResult.get(nodeName);
                    tempList.add(temp);
                    jsonResult.put(nodeName, tempList);
                }
           }else{
                jsonResult.put(nodeName, temp.toString());
            }
        }
        return jsonResult;
        
    }
}