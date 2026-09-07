import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoServico {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Método para Cadastrar Usuário
  Future<String?> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha
      );

      User? usuario = userCredential.user;

    if (usuario != null) {
      // 1. Atualiza o nome de exibição no Firebase Auth
      await usuario.updateDisplayName(nome);
      // 2. Força a sincronização dos dados do usuário com o Firebase
      await usuario.reload();
    }

    return null; // Sucesso
  } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Este endereço de e-mail já está em uso por outra conta.';
        case 'weak-password':
          return 'A senha fornecida é muito fraca. Digite pelo menos 6 caracteres.';
        case 'invalid-email':
          return 'O endereço de e-mail fornecido é inválido.';
        case 'network-request-failed':
          return 'Sem conexão com a internet. Verifique sua rede e tente novamente.';
        default:
          return e.message ?? 'Erro desconhecido ao cadastrar usuário.';
      }
    } catch (e) {
      return 'Ocorreu um erro inesperado: $e';
    }
  }

  // Método para Logar Usuário
  Future<String?> logarUsuario({
    required String email,
    required String senha,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Nenhum usuário correspondente a este e-mail foi localizado.';
        case 'wrong-password':
          return 'A senha digitada está incorreta.';
        case 'invalid-credential':
          return 'As credenciais de acesso fornecidas são inválidas.';
        case 'user-disabled':
          return 'Esta conta de usuário foi desativada.';
        case 'network-request-failed':
          return 'Sem conexão com a internet. Verifique sua rede e tente novamente.';
        default:
          return e.message ?? 'Erro ao realizar login.';
      }
    } catch (e) {
      return 'Ocorreu um erro inesperado: $e';
    }
  }

  // Método para Redefinir Senha (Esqueci minha senha)
  Future<String?> redefinirSenha(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Nenhum usuário foi localizado com este endereço de e-mail.';
        case 'invalid-email':
          return 'O formato do e-mail inserido é inválido.';
        case 'network-request-failed':
          return 'Sem conexão com a internet. Verifique sua rede e tente novamente.';
        default:
          return e.message ?? 'Erro ao solicitar a redefinição de senha.';
      }
    } catch (e) {
      return 'Ocorreu um erro inesperado: $e';
    }
  }

  // Retorna o usuário atualmente autenticado
  User? get usuarioAtual => _firebaseAuth.currentUser;

  // Atualiza o nome de exibição no Firebase Auth
  Future<String?> atualizarPerfilUsuario({required String nome}) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updateDisplayName(nome);
        await user.reload();
        return null; // Sucesso
      }
      return 'Nenhum usuário logado.';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Erro ao atualizar o perfil.';
    } catch (e) {
      return 'Erro inesperado: $e';
    }
  }

  // Método para Deslogar Usuário
  Future<void> deslogarUsuario() async {
    await _firebaseAuth.signOut();
  }

  // Método para Excluir permanentemente a conta do usuário
  Future<String?> excluirContaUsuario() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
        return null; // Sucesso
      }
      return 'Nenhum usuário logado localizado.';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'requires-recent-login':
          return 'Por motivos de segurança, faça login novamente antes de excluir sua conta.';
        case 'network-request-failed':
          return 'Sem conexão com a internet. Verifique sua rede e tente novamente.';
        default:
          return e.message ?? 'Erro ao tentar excluir a conta.';
      }
    } catch (e) {
      return 'Ocorreu um erro inesperado: $e';
    }
  }
}
