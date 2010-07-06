# encoding: utf-8
module Mongoid #:nodoc:
  module Userstamps
    
    extend ActiveSupport::Concern
    
    included do
      
      field :created_by, :type => String, :accessible => false
      field :updated_by, :type => String, :accessible => false
      field :owned_by,   :type => String, :accessible => false
      
      set_callback :create, :before, :set_created_by
      set_callback :save,   :before, :set_updated_by

      class_inheritable_accessor :record_userstamps, :instance_writer => false
      self.record_userstamps = true
      
      #self.attr_protected :created_by, :updated_by, :owned_by
      
    end

    # Update the created_at field on the Document to the current time. This is
    # only called on create.
    def set_created_by
    
      self.created_by = User.current if !created_by
      self.owned_by   = User.current if !owned_by
    
    end

    # Update the updated_at field on the Document to the current time.
    # This is only called on create and on save.
    def set_updated_by
    
      self.updated_by = User.current
    
    end
    
  end
end