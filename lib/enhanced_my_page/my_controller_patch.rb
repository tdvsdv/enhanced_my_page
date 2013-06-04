module EnhancedMyPage
  module MyControllerPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)  

      base.class_eval do
        #after_filter :page_with_enhanced_my_page
        alias_method_chain :page, :enhanced_my_page
        alias_method_chain :page_layout, :enhanced_my_page
        alias_method_chain :add_block, :enhanced_my_page
        before_filter :get_enhanced_default_layout

        helper :queries
          include QueriesHelper
        helper :sort
        include SortHelper  
        include IssuesHelper      
      end
      
    end
    
    module ClassMethods     
    end
    
    module InstanceMethods
      def page_with_enhanced_my_page
        page_without_enhanced_my_page 
        @blocks = @user.pref[:my_page_layout] || @enhanced_default_layout
      end 
      
      def page_layout_with_enhanced_my_page
        page_layout_without_enhanced_my_page  
        @blocks = @user.pref[:my_page_layout] || @enhanced_default_layout
        queries_for_my_page=Query.find(:all, :conditions => ["project_id IS NULL AND is_public=?", true])
        queries_for_my_page.each{|e|
          @block_options << [e.name.to_s, "query#{e.id}"]
        }
      end       
      
      def get_enhanced_default_layout
        @enhanced_default_layout ||= {'left' => Setting.plugin_enhanced_my_page['default_my_page_blocks_left'], 
                       'right' => Setting.plugin_enhanced_my_page['default_my_page_blocks_right'],
                       'top' => Setting.plugin_enhanced_my_page['default_my_page_blocks_top']
                       }          
      end

      def add_block_with_enhanced_my_page
        block = params[:block].to_s.underscore
        @user = User.current
        if !block.nil? && block != ""        
          layout = @user.pref[:my_page_layout] || {}
          # remove if already present in a group
          %w(top left right).each {|f| (layout[f] ||= []).delete block }
          # add it on top
          layout['top'].unshift block
          @user.pref[:my_page_layout] = layout
          @user.pref.save
        end

        redirect_to :action => 'page_layout'          
      end

    end
  end
end