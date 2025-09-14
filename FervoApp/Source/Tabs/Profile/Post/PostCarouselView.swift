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
    @EnvironmentObject var viewModel: ProfileViewModel
    let currentUserModel: UserModel?
    @Binding var selectedIndex: Int
    var onDismiss: () -> Void
    @State private var selectedPostForComments: Post?

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
            
            Divider()
                .padding([.horizontal, .bottom], 0)
                .background(Color.gray)
            
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(Array(posts.enumerated()), id: \.element.id) { index, post in
                            VStack {
                                ProfilePostCardView(
                                    post: post,
                                    onCommentTapped: { selectedPostForComments = post },
                                    onLikeTapped: { viewModel.fetchUserPosts(firebaseUID: currentUserModel?.firebaseUid ?? "") },
                                    onPostTapped: { }
                                )
                                .padding(.top, index == 0 ? 20 : 0)
                                .padding(.bottom, index == posts.count - 1 ? 100 : 0)
                                .id(index)
                                
                                if index != posts.count - 1 {
                                    Divider()
                                        .background(Color.gray) 
                                        .padding(.top, 20)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        proxy.scrollTo(selectedIndex, anchor: .center)
                    }
                }
                .onChange(of: selectedIndex) { newIndex in
                    DispatchQueue.main.async {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
                .background(Color.fvBackground)
                .ignoresSafeArea()
                .sheet(item: $selectedPostForComments) { post in
                    CommentsBottomSheetView(
                        userSession: userSession,
                        postId: post.id,
                        onDisappear: { hasNewComment in
                            if hasNewComment {
                               // viewModel.fetch()
                            }
                        }
                    )
                }
            }
        }
        .background(Color.fvBackground)
    }
}
