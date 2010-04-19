class DecisionsController < ApplicationController
  def show
    @decision = Decision.find(params[:id])
    respond_with @decision
  end
end
