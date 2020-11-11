module ProviderInterface
  class NotesController < ProviderInterfaceController
    before_action :set_application_choice

    def index
      @notes = @application_choice.notes.order('created_at DESC')
    end

    def show
      @note = @application_choice.notes.find(params[:id])
    end

    def new
      @new_note_form = ProviderInterface::NewNoteForm.new
    end

    def create
      @new_note_form = ProviderInterface::NewNoteForm.new new_note_params

      if @new_note_form.save
        flash[:success] = 'Note successfully added'
        redirect_to provider_interface_notes_path(@application_choice)
      else
        render(action: :new)
      end
    end

  private

    def new_note_params
      params.require(:provider_interface_new_note_form).permit(:subject, :message).merge \
        application_choice: @application_choice,
        provider_user: current_provider_user
    end
  end
end
