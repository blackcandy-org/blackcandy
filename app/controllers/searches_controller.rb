# frozen_string_literal: true

class SearchesController < ApplicationController
  AVAILABLE_RESOURCES = %w(albums artists songs)

  def create
    session[:query] = params[:query]
    redirect_to resource_path
  end

  def destroy
    session[:query] = nil
    redirect_to resource_path
  end

  private

    def resource_path
      if AVAILABLE_RESOURCES.include? params[:resource]
        send("#{params[:resource]}_path", query: session[:query])
      else
        albums_path(query: session[:query])
      end
    end
end
