<aura:application extends="force:slds">
    
        <aura:attribute name="caseId" type="String" />
        <aura:attribute name="Inspections" type="String" />
        <aura:attribute name="Logistics" type="String" />
        <aura:if isTrue="{! v.Logistics == 'true'}" >
            <c:PrintLogistics caseId = "{!v.caseId}"/>
        </aura:if>
        <aura:if isTrue="{! v.Inspections == 'true'}">
            <c:PrintPaidInspectionResults caseId = "{!v.caseId}"/>
        </aura:if>
   
</aura:application>