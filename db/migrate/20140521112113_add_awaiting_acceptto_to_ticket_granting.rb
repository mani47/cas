class AddAwaitingAccepttoToTicketGranting < ActiveRecord::Migration
  def change
    add_column :casino_ticket_granting_tickets, :awaiting_acceptto_authentication, :boolean
  end
end
