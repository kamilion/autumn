# Controller and model for the Banhammer leaf

class Controller < Autumn::Leaf
  
  # Banhammers the unfortunate argument of this command.
  
  def banhammer_command(stem, sender, reply_to, msg)
    if msg.nil? then render :help
    else banhammer msg.capitalize end
  end
  ann :banhammer_command, :protected => true
  
  # Displays information about the leaf.
  
  def about_command(stem, sender, reply_to, msg)
  end
  
  private
  
  def banhammer(victim)
    var :victim => victim
    var :return => `sudo iptables -A INPUT -s #{victim} -j DROP; echo -n Killed #{victim}`
  end
end
