# Falta verificar se no windows o caminho está em bom termo
# Falta adicionar o Gem que permite drag and drop de arquivos para organizar
# Falta adicionar o Gem que permite criar uma interface gráfica para o menu, tornando mais amigável
require 'active_record'
require 'bcrypt'
require 'fileutils'

# Conexão com o Banco de Dados
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'arquivista.db'
)

# Definição do Scaffold
class User < ActiveRecord::Base
  include BCrypt
  has_many :archives

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password) # Algoritimo de Hash de senha
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end

# Definição do Modelo Archive
class Archive < ActiveRecord::Base
  belongs_to :user
end

#  Garante que as tabelas existam
unless ActiveRecord::Base.connection.table_exists?(:users)
  ActiveRecord::Schema.define do
    create_table :users do |t|
      t.string :username, null: false
      t.string :password_hash, null: false
    end
    add_index :users, :username, unique: true

    create_table :archives do |t|
      t.integer :user_id
      t.string :name
      t.string :category
      t.string :path
    end
  end
end

# Ruby é linguagem sequencial, sequencialidade essencial
print "Digite seu nome de usuário: "
nome_usuario = gets.chomp

# Ruby identifica se o usuário existe ou cria um novo, solicitando senha
user = User.find_or_create_by(username: nome_usuario) do |u|
  print "Usuário novo! Defina uma senha: "
  u.password = gets.chomp
end

puts "\nOlá, #{user.username}! O sistema está pronto."


# ... restante do menu de organização ...
# Mantendo a configuração basica do sistema original
EXTENSION_MAP = {
  'png'  => 'imagens/png', 'jpg' => 'imagens/jpg', 'jpeg' => 'imagens/jpg',
  'pdf'  => 'documentos/pdf', 'docx' => 'documentos/word',
  'xlsx' => 'documentos/excel', 'mp3' => 'multimedia/audio',
  'zip'  => 'compactados', 'rar' => 'compactados'
}

# Menu de Ações
loop do
  puts "\n--- Menu do Arquivista ---"
  puts "1. Organizar uma pasta agora"
  puts "2. Ver histórico de arquivos organizados" # C
  puts "3. Sair"
  print "Escolha uma opção: "
  opcao = gets.chomp

  case opcao
  when "1"
    print "Digite o caminho da pasta para organizar (ex: ./testes): "
    caminho_origem = gets.chomp

    if Dir.exist?(caminho_origem)
      # Escaneando arquivos assim como no app.py original
      Dir.glob("#{caminho_origem}/*").each do |arquivo_caminho|
        next if File.directory?(arquivo_caminho) # Ignora subpastas

        nome_arquivo = File.basename(arquivo_caminho)
        extensao = File.extname(arquivo_caminho).delete('.').downcase
        categoria = EXTENSION_MAP[extensao] || 'outros'

        # Define o destino usando o nome do usuário para isolamento
        diretorio_destino = File.join("storage", user.username, categoria)
        FileUtils.mkdir_p(diretorio_destino)

        # Move o arquivo fisicamente
        FileUtils.mv(arquivo_caminho, File.join(diretorio_destino, nome_arquivo))

        # Salva o registro no banco de dados
        user.archives.create(name: nome_arquivo, category: categoria, path: diretorio_destino)
        puts "arquivo => [#{categoria.upcase}] -> #{nome_arquivo} => foi movido!"
      end
    else
      puts " Pasta não encontrada! Verifique o caminho."
    end

  when "2"
    puts "\n--- Histórico de #{user.username} ---"
    if user.archives.empty?
      puts "Nenhum arquivo organizado ainda. Vamos organizar algo?"
    else
      user.archives.each do |arq|
        puts "📂 #{arq.name} | Categoria: #{arq.category} | Local: #{arq.path}"
      end
    end

  when "3"
    puts "Encerrando... Até logo, #{user.username}!"
    break
  else
    puts "Opção inválida. Tente novamente!"
  end
end
