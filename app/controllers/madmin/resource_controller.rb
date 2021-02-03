module Madmin
  class ResourceController < ApplicationController
    before_action :set_record, except: [:index, :new, :create]
    before_action :set_page_title

    def index
      @pagy, @records = pagy(scoped_resources)
    end

    def show
    end

    def new
      @record = resource.model.new
    end

    def create
      @record = resource.model.new(resource_params)
      if @record.save
        redirect_to resource.show_path(@record)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @record.update(resource_params)
        redirect_to resource.show_path(@record)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @record.destroy
      redirect_to resource.index_path
    end

    private

    def set_record
      @record = resource.model.find(params[:id])
    end

    def resource
      @resource ||= resource_name.constantize
    end
    helper_method :resource

    def resource_name
      "#{controller_path.singularize}_resource".delete_prefix("madmin/").classify
    end

    def scoped_resources
      resource.model.send(valid_scope)
    end

    def valid_scope
      scope = params.fetch(:scope, "all")
      resource.scopes.include?(scope.to_sym) ? scope : :all
    end

    def resource_params
      params.require(resource.param_key)
        .permit(*resource.permitted_params)
        .transform_values { |v| change_polymorphic(v) }
    end

    def change_polymorphic(data)
      return data unless data.is_a?(ActionController::Parameters) && data[:type]

      if data[:type] == "polymorphic"
        GlobalID::Locator.locate(data[:value])
      else
        raise "Unrecognised param data: #{data.inspect}"
      end
    end
    
    def set_page_title
      @page_title = controller_name.capitalize
    end
  end
end
