//
//  CommentsBottomSheetView.swift
//  
//
//  Created by Leonardo Jose De Oliveira Portes on 20/07/25.
//


struct CommentsBottomSheetView: View {
    @StateObject private var viewModel = CommentsViewModel()
    @ObservedObject private var keyboard = KeyboardResponder()
    let userSession: UserSession
    var postId: String
    @State private var newComment: String = ""
    @State private var hasNewComment = false
    let onDisappear: (Bool) -> Void

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    if viewModel.comments.isEmpty {
                        Text("Ainda não há\n nenhum comentário")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.top, 200)
                            .padding(.bottom, 60)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.gray)
                    } else {
                        ForEach(viewModel.comments, id: \.self) { comment in
                            HStack(alignment: .top, spacing: 12) {
                                AsyncImage(url: URL(string: comment.user.image?.photoURL ?? "")) { image in
                                    image.resizable()
                                        .scaledToFill()
                                        .frame(width: 35, height: 35)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                        .shadow(radius: 2)
                                } placeholder: {
                                    Color.gray.opacity(0.3).frame(width: 40, height: 40).clipShape(Circle())
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("@\(comment.user.username)")
                                            .font(.caption.bold())
                                            .foregroundColor(.white)

                                        Text(comment.createdAt.timeAgoSinceDate)
                                            .font(.caption)
                                            .foregroundColor(.gray)

                                        Spacer()
                                    }

                                    Text(comment.text)
                                        .font(.footnote)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.leading, 16)
                            .padding(.top, 10)
                        }
                    }
                }
            }
            .padding(.bottom, 50)

            Spacer()

            HStack {
                TextField(
                    "",
                    text: $newComment,
                    prompt: Text("Adicione um comentário...")
                        .foregroundColor(.gray)
                )
                .padding(12)
                .background(Color.FVColor.headerCardbackgroundColor)
                .cornerRadius(8)
                .foregroundColor(.white)
                .onChange(of: newComment) { newValue in
                    if newValue.count > 50 {
                        newComment = String(newValue.prefix(50))
                    }
                }

                Button(action: {
                    if let firebaseUid = userSession.currentUser?.firebaseUid {
                        viewModel.sendComment(postID: postId, firebaseUID: firebaseUid, text: newComment) { result in
                            switch result {
                            case .success:
                                hasNewComment = true
                                newComment = ""
                                viewModel.fetchComments(for: postId)
                            case .failure(let error):
                                hasNewComment = false
                                print("Erro ao enviar comentário: \(error.localizedDescription)")
                            }
                        }
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .frame(height: 400)
        .padding(.bottom, keyboard.currentHeight) // 👈 Ajusta ao teclado
        .animation(.easeOut(duration: 0.25), value: keyboard.currentHeight)
        .onAppear {
            viewModel.fetchComments(for: postId)
        }
        .onDisappear {
            onDisappear(hasNewComment)
        }
        .background(Color.fvCardBackgorund)
    }
}
