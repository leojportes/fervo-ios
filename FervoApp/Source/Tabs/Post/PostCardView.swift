//
//  PostCardView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 25/05/25.
//

import SwiftUI

struct PostCardView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var userSession: UserSession
    let post: Post
    var onCommentTapped: (() -> Void)? = nil
    var onLikeTapped: () -> Void
    var onPostTapped: (() -> Void)? = nil

    @State private var isLiked: Bool = false
    @State private var isShowingCommentsSheet: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button(action: {
                onPostTapped?()
            }) {
                HStack(spacing: 12) {
                    RemoteImage(url: URL(string: post.userPost.image?.photoURL ?? ""))
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text("@\(post.userPost.username)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Text(post.createdAt.timeAgoSinceDate)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()
                }
            }

            Button(action: {
                onPostTapped?()
            }) {
                RemoteImage(url: URL(string: post.image.photoURL ?? ""))
                    .frame(maxWidth: .infinity, minHeight: 320, maxHeight: 320)
                    .clipped()
            }
            // Like info and button
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    Button(action: {
                        if !post.hasMyLike(firebaseUid: userSession.currentUser?.firebaseUid ?? "") {
                            viewModel.likePost(postID: post.id, firebaseUID: userSession.currentUser?.firebaseUid ?? "") { result in
                                switch result {
                                case .success(_):
                                    isLiked = true
                                    onLikeTapped()
                                case .failure(_):
                                    isLiked = false
                                }
                            }
                        } else {
                            viewModel.dislikePost(postID: post.id, firebaseUID: userSession.currentUser?.firebaseUid ?? "") { result in
                                switch result {
                                case .success(_):
                                    isLiked = false
                                    onLikeTapped()
                                case .failure(_):
                                    isLiked = true
                                }
                            }
                        }

                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: post.hasMyLike(firebaseUid: userSession.currentUser?.firebaseUid ?? "") ? "heart.fill" : "heart")
                                .foregroundColor(post.hasMyLike(firebaseUid: userSession.currentUser?.firebaseUid ?? "") ? .red : .gray)
                                .font(.system(size: 20))
                            Text("\(post.likedBy?.count ?? 0)")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                    }

                    Button(action: {
                        onCommentTapped?()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 18))
                            Text("\(post.comments?.count ?? 0)")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                    }

                    Spacer()
                }

                HStack {
                    HStack(spacing: -6) {
                        if let likedUsers = post.likedUsers {
                            ForEach(likedUsers.prefix(3), id: \.firebaseUid) { user in
                                RemoteImage(url: URL(string: user.image?.photoURL ?? ""))
                                    .frame(width: 20, height: 20)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                            }
                        }

                    }
                    if let likedUsers = post.likedBy {
                        if likedUsers.count > 0 {
                            Text(post.likeDescription)
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        Spacer()
                    }

                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.FVColor.cardBackground)
        .cornerRadius(20)
        .shadow(color: .gray.opacity(0.08), radius: 4, x: 0, y: 4)
        .padding(.vertical, 8)
    }
}
