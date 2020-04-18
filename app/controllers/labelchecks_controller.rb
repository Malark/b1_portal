class LabelchecksController < ApplicationController

  def search_delivery

  end
  
  def set_delivery
    obj = params[:labelcheck][:docnum]
    delivery_note = obj[1,obj.length-1]
    #puts delivery_note
    elem = ODLN.(DocNum: delivery_note.to_i)
    if elem
      fla h[:success] = "Van ilyen szállítólevél"
      redirect_to labelcheck_path(elem)
    else
      render 'search_delivery'
    end
  end

  def check
    @elem = ODLN.find_by(DocEntry: params[:format])
  end

  def check_delivery
    @master_labels = params[:labels]
    session[:labels] = @master_labels
    session[:checkable_labels] = @master_labels
    session[:checked_labels] = []
    @finished = false
  end

  def check_labels
    if params[:labelcheck22].blank?
      flash.now[:danger] = "Nem adott meg érvényes vonalkódot!"
      #puts '+++Nem adott meg vonalkódot'
    else
      label = params[:labelcheck22]
      #In case of AUDI (label example: 6JUN364740217000070179)
      if label.length == 22 
        label = (label[13,label.length-1]).to_i.to_s
      else  #Volvo, Daimler, BMW  (label example: M77079)
        if label.length > 1 
          label = label[1,label.length-1]
        end
      end
      if checkable_label(label)
        session[:checked_labels].push(label)    
        session[:checkable_labels].delete(label)
        #flash.now[:success] = "Sikeresen ellenőrzött címke!"
        #puts '+++Sikeres ellenorzes'
      else
        #Check if it was earlier checked
        if checked_label(label)
          flash.now[:danger] = "Már korábban ellenőrzött címke: #{label}"
          #puts '+++Már korábban ellenőrzött címke'
        else
          flash.now[:danger] = "A(z) #{label} sorszámú címke nem található!"
          #puts '+++Nem találhatócímke'
        end
      end
    end
    if session[:checked_labels].count >= session[:labels].count
      #When all the labels are checked
      flash.now[:success] = "A szállítmány ellenőrzése sikeresen befejeződött!"
      @finished = true
      write_data
    end 

    respond_to do |format|
      format.js { render partial: 'labelchecks/check_deliveries' }
    end
  end

  def write_data
    #puts "Update database for checked records"
    MOS_OWSD.update_checked_labels(session[:checked_labels])
  end

  def checked_delivery
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