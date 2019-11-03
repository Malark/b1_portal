# README

Semantic UI bekapcsolása:


-> assets\javascripts\application.js

//= require jquery
//= require semantic-ui

    <%= @deliveries.each do |row| %>
      <strong>Delivery Note Nr: </strong><%= row["DocNum"] %>
    <% end %>

    <%= f.collection_check_boxes :delivery_docentries, @deliveries.all, :DocEntry, DocNum do |cb| %>
      <% cb.label(class: "checkbox-inline input_checkbox") {cb.check_box(class: "checkbox") + cb.text} %>
    <% end %>  

    <% @choosen_deliveries.each do |row| %>
      <ul>
        <li><%= row %></li>
      </ul>
    <% end %>  


-> assets\stylesheets\custom.css.scss

@import "semantic-ui";



ez működött, de csak az utolsó kiválaszottt elemre:

def choose
    @step2 = true

    if params[:name].blank?
      flash.now[:danger] = "Legalább 1 szállítólevél kiválasztása kötelező!"
    else
      @choosen_deliveries = params[:name]
    end
    respond_to do |format|
      format.js { render partial: 'labelchecks/deliveries' }
    end
  end


_deliveries.html.erb:

<li>
  <label class="category-select">
    <%= check_box_tag :name, row["DocNum"], false %>
    <%= row["DocNum"] %>, <%= row["DocDate"] %>
  </label>
</li>

.
.
.

<% else %>
  <% if @choosen_deliveries %>
    <strong>Master címkék ellenőrzése!</strong>
    <%= @choosen_deliveries %>
  <% end %>  
<% end %>
