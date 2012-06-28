Redmine::Plugin.register :enhanced_my_page do
	name 'Enhanced My Page plugin'
	author 'Pitin Vladimir Vladimirovich'
	description 'This is a plugin for enhancing my page'
	version '0.0.1'
	url 'http://pitin.su'
	author_url 'http://pitin.su'
  
	settings	:partial => 'settings/enhanced_my_page',
				:default => {
				  "default_my_page_blocks_left" => ['issuesassignedtome'], 
				  "default_my_page_blocks_right" => ['issueswatched', 'issuesreportedbyme'], 
				  "default_my_page_blocks_top" => []
				}  	
end

Rails.application.config.to_prepare do
	MyController.send(:include, EnhancedMyPage::MyControllerPatch)
end