class SessionsController < ApplicationController
  def create
    @session = Session.create params[:session]

    if @session.new_record?
      render :json => {
        :errors => @session.errors
      }, :status => 400
    else
      render :json => {
        :id => @session.id
      }
    end
  end

  def destroy
    @session = Session.find(params[:id]) rescue nil
    if @session
      @session.kill
      render :json => {}
    else
      render :json => {
        :errors => ["Session not found"]
      }, :status => 400
    end
  end
end
