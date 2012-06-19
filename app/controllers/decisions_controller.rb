class DecisionsController < ApplicationController
  def show
    decision = co.decisions.find(params[:id])
    redirect_to proposal_path(decision.proposal)
  end
end
