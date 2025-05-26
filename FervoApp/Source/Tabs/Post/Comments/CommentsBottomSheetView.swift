//
//  CommentsBottomSheetView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 25/05/25.
//

import SwiftUI

struct CommentsBottomSheetView: View {
    @StateObject private var viewModel = CommentsViewModel()
    var postId: String
    @State private var newComment: String = ""

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if viewModel.comments.isEmpty {
                        Text("Ainda não há\n nenhum comentário")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.top, 200)
                            .padding(.bottom, 60)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    } else {
                        ForEach(viewModel.comments, id: \.self) { comment in
                            HStack(alignment: .top, spacing: 12) {
                                AsyncImage(url: URL(string: comment.user.image?.photoURL ?? "")) { image in
                                    image.resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                        .shadow(radius: 2)
                                } placeholder: {
                                    Color.gray.opacity(0.3).frame(width: 40, height: 40).clipShape(Circle())
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(comment.user.username)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)

                                    Text(comment.createdAt)
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Spacer()
                                }

                                Text(comment.text)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                        }
                        .padding(.vertical, 4)

                    }
                }
            }

            Spacer()

            HStack {
                TextField("Adicione um comentário...", text: $newComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 44)
                    .onChange(of: newComment) { newValue in
                        if newValue.count > 50 {
                            newComment = String(newValue.prefix(50))
                        }
                    }

                Button(action: {
                    viewModel.sendComment(postID: postId, userID: "", text: newComment) { result in
                        switch result {
                        case .success:
                            newComment = ""
                            viewModel.fetchComments(for: postId)
                        case .failure(let error):
                            print("Erro ao enviar comentário: \(error.localizedDescription)")
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
        .onAppear {
            viewModel.fetchComments(for: postId)
        }
    }
}
