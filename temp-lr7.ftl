<div id="customTemplateAsset">
<h3>Tin tức nổi bật</h3>
<#if !entries?has_content>
	<#if !themeDisplay.isSignedIn()>
		${renderRequest.setAttribute("PORTLET_CONFIGURATOR_VISIBILITY", true)}
	</#if>

	<div class="alert alert-info">
		<@liferay_ui["message"]
			key="there-are-no-results"
		/>
	</div>
</#if>

<#assign idEntry = 0 />
<#list entries as entry>
	<#assign entry = entry />

	<#assign assetRenderer = entry.getAssetRenderer() />

	<#assign entryTitle = htmlUtil.escape(assetRenderer.getTitle(locale)) />

	<#assign viewURL = assetPublisherHelper.getAssetViewURL(renderRequest, renderResponse, entry) />

	<#if assetLinkBehavior != "showFullContent">
		<#assign viewURL = assetPublisherHelper.getAssetViewURL(renderRequest, renderResponse, entry, true) />
	</#if>

    <#if (entry?index < 5)>
        <div class="asset-entry-full-content">
        <div class="asset-entry-abstract-image">
         <#-- ${assetRenderer.getThumbnailPath(renderRequest)} -->
         <#assign thumbnailPath = assetRenderer.getThumbnailPath(renderRequest)!"/Content/Images/no-available-image.png" >
    	   <img src="${thumbnailPath}"  onerror="if (this.src != '/Content/Images/no-available-image.png') this.src = '/Content/Images/no-available-image.png';"/>
    	</div>
    	<div class="asset-abstract">
    		<div class="lfr-meta-actions asset-actions">
    			<@getPrintIcon />
               
    			<@getFlagsIcon />
    
    			<@getEditIcon />
    		</div>
    
    		<div class="asset-title">
    			<a href="${viewURL}">
    				${entryTitle}
    			</a>
    		</div>
    
    			<div class="asset-summary">
    				${htmlUtil.escape(assetRenderer.getSummary(renderRequest, renderResponse))}
    
    			</div>
    	</div>
    	</div>
    	<div class="clearfix"></div>
    <#else>
        <#if (entry?is_last)>
            </ul></div>
        <#else>
            <#assign idEntry = (entry?index - 5)/10 />
            <#if (entry?index == 5)>
                <div id="ulPagination"><span class="other-title">Các tin khác</span>
                <ul id="page${idEntry?floor}" class="entry-more-active">
                <li style=""><a href="${viewURL}" class="title_news_link_a" title="${entryTitle}">
               ${entryTitle}</a><@getEditIcon /></li>
            <#else>
               <#if ((entry?index - 5) % 10) == 0>
                     </ul><ul id="page${idEntry?floor}" class="entry-more-hide">
                </#if>           
                <li style=""><a href="${viewURL}" class="title_news_link_a" title="${entryTitle}">
               ${entryTitle}</a><@getEditIcon /></li>
            </#if>
        </#if>
    </#if>
</#list>
</ul>
<input type="hidden" id="pageIndex" value="0">


<#if (idEntry?floor > 0) >
	<div id="entryPagnation">
	    <a id="paginationFirst" class="pagerButton pag-display-none" href="javascript:changePageEntry(0)"></a>
	    
	    <a id="pagination1" class="pagerButton pag-active" href="javascript:changePageEntry(0)">1</a>
	    <a id="pagination2" class="pagerButton" href="javascript:changePageEntry(1)">2</a>
	    
	    <a id="paginationNext" class="pagerButton" href="javascript:changePageEntry(1)"></a>
	</div>
</#if>


<#macro getDiscussion>
	<#if getterUtil.getBoolean(enableComments) && assetRenderer.isCommentable()>
		<br />

		<#assign discussionURL = renderResponse.createActionURL() />

		${discussionURL.setParameter("javax.portlet.action", "invokeTaglibDiscussion")}

		<@liferay_ui["discussion"]
			className=entry.getClassName()
			classPK=entry.getClassPK()
			formAction=discussionURL?string
			formName="fm" + entry.getClassPK()
			ratingsEnabled=getterUtil.getBoolean(enableCommentRatings)
			redirect=currentURL
			userId=assetRenderer.getUserId()
		/>
	</#if>
</#macro>

<#macro getFlagsIcon>
	<#if getterUtil.getBoolean(enableFlags)>
		<@liferay_flags["flags"]
			className=entry.getClassName()
			classPK=entry.getClassPK()
			contentTitle=entry.getTitle(locale)
			label=false
			reportedUserId=entry.getUserId()
		/>
	</#if>
</#macro>

<#macro getEditIcon>
	<#if assetRenderer.hasEditPermission(themeDisplay.getPermissionChecker())>
		<#assign redirectURL = renderResponse.createRenderURL() />

		${redirectURL.setParameter("mvcPath", "/add_asset_redirect.jsp")}
		${redirectURL.setWindowState("pop_up")}

		<#assign editPortletURL = assetRenderer.getURLEdit(renderRequest, renderResponse, windowStateFactory.getWindowState("pop_up"), redirectURL)!"" />

		<#if validator.isNotNull(editPortletURL)>
			<#assign title = languageUtil.format(locale, "edit-x", entryTitle, false) />

			<@liferay_ui["icon"]
				iconCssClass="icon-edit-sign"
				message=title
				url="javascript:Liferay.Util.openWindow({id:'" + renderResponse.getNamespace() + "editAsset', title: '" + title + "', uri:'" + htmlUtil.escapeURL(editPortletURL.toString()) + "'});"
			/>
		</#if>
	</#if>
</#macro>

<#macro getMetadataField
	fieldName
>
	<#if stringUtil.split(metadataFields)?seq_contains(fieldName)>
		<span class="metadata-entry metadata-${fieldName}">
			<#assign dateFormat = "dd MMM yyyy - HH:mm:ss" />

			<#if fieldName == "author">
				<@liferay.language key="by" /> ${portalUtil.getUserName(assetRenderer.getUserId(), assetRenderer.getUserName())}
			<#elseif fieldName == "categories">
				<@liferay_ui["asset-categories-summary"]
					className=entry.getClassName()
					classPK=entry.getClassPK()
					portletURL=renderResponse.createRenderURL()
				/>
			<#elseif fieldName == "create-date">
				${dateUtil.getDate(entry.getCreateDate(), dateFormat, locale)}
			<#elseif fieldName == "expiration-date">
				${dateUtil.getDate(entry.getExpirationDate(), dateFormat, locale)}
			<#elseif fieldName == "modified-date">
				${dateUtil.getDate(entry.getModifiedDate(), dateFormat, locale)}
			<#elseif fieldName == "priority">
				${entry.getPriority()}
			<#elseif fieldName == "publish-date">
				${dateUtil.getDate(entry.getPublishDate(), dateFormat, locale)}
			<#elseif fieldName == "tags">
				<@liferay_ui["asset-tags-summary"]
					className=entry.getClassName()
					classPK=entry.getClassPK()
					portletURL=renderResponse.createRenderURL()
				/>
			<#elseif fieldName == "view-count">
				${entry.getViewCount()} <@liferay.language key="views" />
			</#if>
		</span>
	</#if>
</#macro>

<#macro getPrintIcon>
	<#if getterUtil.getBoolean(enablePrint)>
		<#assign printURL = renderResponse.createRenderURL() />

		${printURL.setParameter("mvcPath", "/view_content.jsp")}
		${printURL.setParameter("assetEntryId", entry.getEntryId()?string)}
		${printURL.setParameter("viewMode", "print")}
		${printURL.setParameter("type", entry.getAssetRendererFactory().getType())}

		<#if assetRenderer.getUrlTitle()?? && validator.isNotNull(assetRenderer.getUrlTitle())>
			<#if assetRenderer.getGroupId() != themeDisplay.getScopeGroupId()>
				${printURL.setParameter("groupId", assetRenderer.getGroupId()?string)}
			</#if>

			${printURL.setParameter("urlTitle", assetRenderer.getUrlTitle())}
		</#if>

		${printURL.setWindowState("pop_up")}

		<@liferay_ui["icon"]
			iconCssClass="icon-print"
			message="print"
			url="javascript:Liferay.Util.openWindow({id:'" + renderResponse.getNamespace() + "printAsset', title: '" + languageUtil.format(locale, "print-x-x", ["hide-accessible", entryTitle], false) + "', uri: '" + htmlUtil.escapeURL(printURL.toString()) + "'});"
		/>
	</#if>
</#macro>

<#macro getRatings>
	<#if getterUtil.getBoolean(enableRatings) && assetRenderer.isRatable()>
		<div class="asset-ratings">
			<@liferay_ui["ratings"]
				className=entry.getClassName()
				classPK=entry.getClassPK()
			/>
		</div>
	</#if>
</#macro>

<#macro getRelatedAssets>
	<#if getterUtil.getBoolean(enableRelatedAssets)>
		<@liferay_ui["asset-links"]
			assetEntryId=entry.getEntryId()
		/>
	</#if>
</#macro>

<#macro getSocialBookmarks>
	<#if getterUtil.getBoolean(enableSocialBookmarks)>
		<@liferay_ui["social-bookmarks"]
			displayStyle="${socialBookmarksDisplayStyle}"
			target="_blank"
			title=entry.getTitle(locale)
			url=viewURL
		/>
	</#if>
</#macro>
</div>
<script>
function changePageEntry(type) {
    var indexActive = Number($('#pageIndex').val());
    
    if (type==0) {
        $('#page'+indexActive).addClass('entry-more-hide');
        $('#page'+indexActive).removeClass('entry-more-active');
        $('#page0').removeClass('entry-more-hide');
        $('#page0').addClass('entry-more-active');
        $('#pageIndex').val(0);
        $('#pagination1').addClass('pag-active');
        $('#pagination2').removeClass('pag-active');
        $('#paginationFirst').addClass('pag-display-none');
        $('#paginationNext').removeClass('pag-display-none');
    } else {
        if ($('#page'+(indexActive+1)).length>0) {
            $('#page'+indexActive).addClass('entry-more-hide');
            $('#page'+indexActive).removeClass('entry-more-active');
            $('#page'+(indexActive+1)).removeClass('entry-more-hide');
            $('#page'+(indexActive+1)).addClass('entry-more-active');
            $('#pageIndex').val(indexActive+1);
            if ($('#page'+(indexActive+2)).length==0) {
            	$('#pagination2').addClass('pag-active');
            	$('#pagination1').removeClass('pag-active');
            }
            $('#paginationFirst').removeClass('pag-display-none');
            $('#paginationNext').addClass('pag-display-none');
        }
    }

}
</script>