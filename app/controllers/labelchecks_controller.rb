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
      flash[:success] = "Van ilyen szállítólevél"
      redirect_to labelcheck_path(elem)
    else
      render 'search_delivery'
    end
  end

  def check
    @elem = ODLN.find_by(DocEntry: params[:format])
  end

  def check_deliveries
    @master_labels = params[:labels]
    session[:labels] = @master_labels
    session[:checkable_labels] = @master_labels
    session[:checked_labels] = []
    puts @master_labels
    @finished = false
  end

  def check_labels
    if params[:labelcheck2].blank?
      flash.now[:danger] = "Nem adott meg érvényes vonalkódot!"
    else
      label = params[:labelcheck2]
      if checkable_label(label)
        session[:checked_labels].push(label)    
        session[:checkable_labels].delete(label)
        #flash.now[:success] = "Sikeresen ellenőrzött címke!"
      else
        #Check if it was earlier checked
        if checked_label(label)
          flash.now[:danger] = "Már korábban ellenőrzött címke: #{label}"
        else
          flash.now[:danger] = "A(z) #{label} sorszámú címke nem található!"
        end
      end
    end
    if session[:checked_labels].count >= session[:labels].count
      #When all the labels are checked
      flash.now[:success] = "A szállítmány ellenőrzése sikeresen befejeződött!"
      @finished = true
    end 

    puts 'Ellenorizendok:'
    puts session[:checkable_labels]
    puts '------------'
    puts 'Ellenorzottek:'
    puts session[:checked_labels]

    respond_to do |format|
      format.js { render partial: 'labelchecks/check_deliveries' }
    end
  end

  def checked_delivery
    puts "HHHHHHHHHHHHHHUUUUUUUUUUUUUUUUUUUUUUURRRRRRRRRRRRRRRÁÁÁÁÁÁÁÁÁÁÁÁÁÁÁÁ"
    render :js => "window.location = '#{root_path}'"
  end
  
  private 
    def checkable_label(label)
      if session[:checkable_labels].include?(label) 
        return true
      else
        return false
      end
    end

    def checked_label(label)
      if session[:checked_labels].include?(label) 
        return true
      else
        return false
      end
    end

end