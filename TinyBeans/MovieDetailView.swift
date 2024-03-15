//
//  MovieDetailView.swift
//  TinyBeans
//
//  Created by Jian Ma on 3/15/24.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: RemoteMovie
    let movieDetail: RemoteMovieDetail?
    
    var body: some View {
        ScrollView {
            ScrollViewHeader {
                ZStack {
                    LinearGradient(
                        colors: [.brown, .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    movie.backdropPath.map { backdropPath in
                        AsyncImage(
                            url: URL(string: imageURLPrefix + backdropPath),
                            content: { image in
                                image
                                    .image?
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        )
                        .frame(height: 200)
                        .cornerRadius(5)
                        .shadow(radius: 10)
                        .padding(.top, 60)
                        .padding(.horizontal, 20)
                        
                    }
                }
            }
            .frame(height: 280)
            
            VStack(alignment: .leading) {
                Text("title: \(movie.title)")
                Text("id: \(String(movie.id))")
                Text("vote count: \(movie.voteCount)")
                Text("overview: \(movie.overview)")
                
            }
            .padding([.leading, .horizontal])

            if let movieDetail {
                Section {
                    Text("Revenue: \(movieDetail.revenue)")
                }
            } else {
                Text("loading...")
                ProgressView()
            }
            
        }
    }
    
    
}

#Preview {
    return MovieDetailView(
        movie: .mockFromBundle,
        movieDetail: nil
    )
}

public struct ScrollViewHeader<Content: View>: View {

    public init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
    }

    private let content: () -> Content

    public var body: some View {
        GeometryReader { geo in
            content().stretchable(in: geo)
        }
    }
}

extension View {

    @ViewBuilder
    func stretchable(in geo: GeometryProxy) -> some View {
        let width = geo.size.width
        let height = geo.size.height
        let minY = geo.frame(in: .global).minY
        let useStandard = minY <= 0
        self.frame(width: width, height: height + (useStandard ? 0 : minY))
            .offset(y: useStandard ? 0 : -minY)
    }
}
