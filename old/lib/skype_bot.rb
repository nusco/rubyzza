require 'win32ole'
require 'z_front_end'


class SkypeBot

  WELCOME_MESSAGE = "(*) Welcome to Rubyzza - A Skype Z-Machine by Paolo Perrotta (*)" <<
                    "\n\nTry typing #help"

  def initialize
    @environment = ZFrontEnd.new([])
    @oSkype = WIN32OLE.new("Skype4COM.Skype")
    @attachment_status_available = @oSkype.Convert.TextToAttachmentStatus("AVAILABLE")
    @message_status_received = @oSkype.Convert.TextToChatMessageStatus("RECEIVED")
    @message_type_said = @oSkype.Convert.TextToChatMessageType("SAID")
    @active_users = []
  end

  def run
    @oSkype.Client.Start() if !@oSkype.Client.IsRunning
    @oSkype.Attach()
    @ev = WIN32OLE_EVENT.new(@oSkype)
    @ev.on_event('AttachmentStatus') {|status|
      @oSkype.Attach() if status = @attachment_status_available
    }
    @ev.on_event('MessageStatus') {|msg, status|
      if status == @message_status_received
        if msg.Type == @message_type_said
          reply = process(msg)
          if reply.size > 0
            @oSkype.SendMessage(msg.FromHandle, reply)
          end
        end
      end
    }
  end
  
  private
  
  def process(msg)
    if @active_users.include?(msg.FromHandle)
      return @environment.process(msg.Body)
    else
      @active_users << msg.FromHandle
      return WELCOME_MESSAGE
    end
  end
end


SkypeBot.new.run
loop do
  WIN32OLE_EVENT.message_loop
end
