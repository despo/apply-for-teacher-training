class DfESignInUser
  attr_reader :email_address, :dfe_sign_in_uid

  def initialize(email_address:, dfe_sign_in_uid:)
    @email_address = email_address
    @dfe_sign_in_uid = dfe_sign_in_uid
  end

  def self.begin_session!(session, dfe_sign_in_session)
    session['dfe_sign_in_user'] = {
      'email_address' => dfe_sign_in_session.email_address,
      'dfe_sign_in_uid' => dfe_sign_in_session.uid,
    }
  end

  def self.load_from_session(session)
    return nil unless session['dfe_sign_in_user']

    if session['dfe_sign_in_user']
      new(
        email_address: session['dfe_sign_in_user']['email_address'],
        dfe_sign_in_uid: session['dfe_sign_in_user']['dfe_sign_in_uid'],
      )
    end
  end

  def self.end_session!(session)
    session.delete('dfe_sign_in_user')
  end
end
