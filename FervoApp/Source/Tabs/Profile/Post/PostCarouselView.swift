//
//  PostCarouselView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 30/08/25.
//

import SwiftUI

struct PostCarouselView: View {
    @Binding var isLoading: Bool
    let posts: [Post]
    @EnvironmentObject var userSession: UserSession
    @Binding var selectedIndex: Int
    var onDismiss: () -> Void


    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    onDismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding([.horizontal, .top], 10)
                }
                .frame(width: 30)

                Spacer()
                VStack(alignment: .center) {
                    Text("Posts")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    Text("@\(posts.first?.userPost.username ?? .empty)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .blurLoading(isLoading, false)
                }
                Rectangle()
                    .foregroundColor(Color.fvBackground)
                    .frame(width: 30, height: 10)

                Spacer()
            }
            .background(Color.fvBackground)
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(posts.enumerated()), id: \.element.id) { index, post in
                            VStack {
                                PostCardView(
                                    post: post,
                                    onCommentTapped: {
                                        //selectedPostForComments = post
                                    },
                                    onLikeTapped: {
                                        // viewModel.fetch()
                                    },
                                    onPostTapped: {
                                        //handlePostTap(post)
                                    }
                                )
                                .environmentObject(userSession)
                                .padding(.horizontal)
                                .padding(.top, 12)
                            }
                            .padding(.top, 12)
                            .padding(.bottom, index == posts.count - 1 ? 150 : 0)
                            .clipped()
                            .id(index)
                            .background(Color.black)
                        }
                    }

                }
                .background(Color.fvBackground)
                .ignoresSafeArea()
                .onAppear {
                    proxy.scrollTo(selectedIndex, anchor: .bottom)
                }
            }
        }
        .background(Color.fvBackground)
    }
}
