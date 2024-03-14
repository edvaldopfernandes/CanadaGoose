public with sharing class WarrantyNavigationMenuController extends LightningController {

    /**
     * Perform two SOQL queries to determine all the children NavigationMenuItems
     * belonging to the provided menuName and publishedState. This example uses the
     * NavigationLinkSet.MasterLabel for the menuName. One could also use the
     * NavigationLinkSet.Id to ensure referential integrity if the MasterLabel changes.
     *
     * NavigationLinkSet contains both Draft and Live versions of the NavigationMenuItems.
     * Use the publishedState enumeration to filter between them.
     *
     * Cacheable = true allows this function to be wired.
     */
    @AuraEnabled(cacheable=true)
    public static List<NavigationMenuItem> getNavigationMenuItems(
        String menuName,
        String publishedState
    ) {
        if (String.isEmpty(menuName)) {
            return new List<NavigationMenuItem>();
        }

        String networkId = Network.getNetworkId();

        if(Test.isRunningTest() && networkId == null) {
            networkId = [SELECT Id FROM Network][0].Id;
        }

        // find the link set belonging to the navigation menuName and active networkId
        List<NavigationLinkSet> linkSets = [
            SELECT Id
            FROM NavigationLinkSet
            WHERE MasterLabel = :menuName AND NetworkId = :networkId
        ];

        Id linkSetId = linkSets.get(0).Id;

        // collect all the menu items belonging to the link set
        // published state is either Draft or Live
        return [
            SELECT
                Label,
                Target,
                Type,
                DefaultListViewId,
                AccessRestriction,
                ParentId,
                Position,
                Status,
                TargetPrefs
            FROM NavigationMenuItem
            WHERE NavigationLinkSetId = :linkSetId AND Status = :publishedState
            ORDER BY Position
        ];
    }

    @AuraEnabled
    public static Response getCarouselImages(){
        try {
            List<WarrantyNavMenuCarousel__mdt> images = [
                SELECT Id,
                    MasterLabel,
                    DeveloperName,
                    ButtonLabel__c,
                    ButtonUrl__c,
                    ImageUrl__c,
                    Title__c,
                    Order__c
                FROM WarrantyNavMenuCarousel__mdt
                WHERE Active__c = true
                ORDER BY Order__c ASC
            ];
            return new Response(true, 'success', (Object) images);
        } catch (Exception e) {
            return new Response(false, e.getMessage());
        }
    }
}