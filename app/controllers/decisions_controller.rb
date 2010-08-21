class DecisionsController < ApplicationController
  def show
    @decision = co.decisions.find(params[:id])
    respond_with @decision
  end
end
