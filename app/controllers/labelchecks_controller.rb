class LabelchecksController < ApplicationController

  def search_delivery
  end

  def set_delivery
    obj = params[:labelcheck][:docnum]
    delivery_note = obj[1,obj.length-1]
    #puts delivery_note
    elem = ODLN.find_by(DocNum: delivery_note.to_i)
    #elem = MOS_OWSD.find_by(U_forrasbiz: delivery_note)
    if elem
      redirect_to labelcheck_path(elem)
    else
      render 'search_delivery'
    end
  end

  def check
    @elem = ODLN.find_by(DocEntry: params[:format])
  end
   
end