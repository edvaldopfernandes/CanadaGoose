public with sharing class ManagedContentController {
    @AuraEnabled(cacheable=true)
    public static Map<String, ConnectApi.ManagedContentNodeValue> getContent(
        String contentId,
        Integer page,
        Integer pageSize,
        String language,
        String filterby
    ) {
        try {
            String networkId = Network.getNetworkId();

            if(Test.isRunningTest() && networkId == null) {
                networkId = [SELECT NetworkId, MemberId FROM NetworkMember WHERE MemberID =:UserInfo.getUserId()][0].NetworkId;
            }

            ConnectApi.ManagedContentVersionCollection contentCollection = ConnectApi.ManagedContent.getManagedContentByContentKeys(
                networkId,
                new List<String>{ contentId },
                0,
                1,
                language,
                filterby,
                false
            );
            return contentCollection.items[0].contentNodes;
        } catch (ConnectApi.ConnectApiException e) {
            System.debug('Error Message : ' + e);
            Map<String, ConnectApi.ManagedContentNodeValue> mcnvMap = new Map<String, ConnectApi.ManagedContentNodeValue>();
            return mcnvMap;
        } catch (ConnectApi.NotFoundException e) {
            System.debug('Error Message : ' + e);
            Map<String, ConnectApi.ManagedContentNodeValue> mcnvMap = new Map<String, ConnectApi.ManagedContentNodeValue>();
            return mcnvMap;
        }
    }
}