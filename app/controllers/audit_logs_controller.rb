class AuditLogsController < ApplicationController

  def index
    @obj = params[:klass].classify.constantize.find(params[:id])
    render 'share/audits', locals: { object: @obj }
  end

end


