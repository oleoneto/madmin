module Madmin
  class ResourceController < ApplicationController
    before_action :set_record, except: [:index, :new, :create]

    def index
      @pagy, @records = pagy(resource.model.all)
    end

    def show
    end

    def new
      @record = resource.model.new
    end

    def create
      @record = resource.model.new(resource_params)
      if @record.save
        redirect_to [:madmin, @record]
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @record.update(resource_params)
        redirect_to [:madmin, @record]
      else
        render :edit
      end
    end

    def destroy
      @record.destroy
      redirect_to [:madmin, resource.model]
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

    def resource_params
      params.require(resource.param_key).permit(*resource.permitted_params)
    end
  end
end