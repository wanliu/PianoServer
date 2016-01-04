class Encryptor
  def initialize(key, salt)
    passphrase = ActiveSupport::KeyGenerator.new(key).generate_key(salt)
    @encryptor = ActiveSupport::MessageEncryptor.new(passphrase)
  end

  def encrypt(plaintext)
    @encryptor.encrypt_and_sign(plaintext)
  end

  def decrypt(encrypted_data)
    @encryptor.decrypt_and_verify(encrypted_data)
  end
end
