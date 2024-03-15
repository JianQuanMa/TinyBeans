//
//  ContentView.swift
//  TinyBeans
//
//  Created by Jian Ma on 3/15/24.
//

import SwiftUI

/*
 
 Screen One
 Load and display at least a grid of images from the “movie/popular”
 endpoint
 https://developers.themoviedb.org/3/movies/get-popular-movies

 Feel free to include other fields in the UI as you feel would be a
 good experience for the user. Movie name, etc.

 Ensure that you handle errors, network connectivity.

 Bonus: Support paging and caching into database for offline use and
 faster load times for the user.

 On click of a movie, navigate to a detail screen
 
 apikey - ba98e6d2ed9093ed17f901d4cb6ecd0b
 
 read access
 eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiYTk4ZTZkMmVkOTA5M2VkMTdmOTAxZDRjYjZlY2QwYiIsInN1YiI6IjY1ZjM5NGU0MjkzODM1MDE4NzI3ZTViNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.zq0byEknt46vrxrtNZUn5roszXRXIBTeglKp5rBGkTY
 
 curl --request GET \
      --url 'https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=en-US&page=1&sort_by=popularity.desc' \
      --header 'Authorization: Bearer ba98e6d2ed9093ed17f901d4cb6ecd0b' \
      --header 'accept: application/json'
 
 */

// ScreenOne
struct ContentView: View {
    
    @MainActor
    final class ViewModel: ObservableObject {
        let client: MovieClient
        @Published var presentedMovie: RemoteMovie?
        @Published var movieDetailsCache: [Int: RemoteMovieDetail] = [:]
        @Published private var movieListState = MovieListState.preload
        @Published var page: Int = 1
        init(client: MovieClient) {
            self.client = client
        }


        var isFetchPopluarListInFlight: Bool {
            if case .isInFlight = movieListState {
                return true
            }

            return false
        }

        var movies: [RemoteMovie] {
            switch movieListState {
            case .loaded(.success(let movies)):
                return movies
            default:
                return []
            }
        }
        
        var errorString: String? {
            switch movieListState {
            case .loaded(.failure(let error)):
                return error.localizedDescription
            default:
                return nil
            }
        }
        
        enum MovieListState {
            case preload
            case isInFlight
            case loaded(Result<[RemoteMovie], Error>)
        }

        private var movieDetailTask: Task<Void, Never>?
        private var totalMoviePages: Int = .zero
        func onAppear() {
            print("-=- on appear happened")
            
            Task { [page] in
                do {
                    self.movieListState = .isInFlight
                    let root = try await client.fetchPopluarList(page)
                    self.totalMoviePages = root.totalPages
                    self.movieListState = .loaded(.success(root.results))
                } catch {
                    self.movieListState = .loaded(.failure(error))
                }
            }
        }
        
        func onMovieTapped(_ movie: RemoteMovie) {
            movieDetailTask?.cancel()

            presentedMovie = movie
            
            movieDetailTask = Task { [movieID = movie.id] in
                do {
                    self.movieDetailsCache[movieID] = try await client.fetchDetailByMovieID(movieID)
                } catch {
                    
                }
            }
        }
        
        var movieListTask: Task<Void, Never>?
        
        func onMovieAppeared(_ movieId: Int) {
            
            /*
             if at the end (or near the end) &&
             i don't have somehting in flight &&
             there are still items in the backend we haven't fetched,
             */
//            movieListTask
            
            print("-=- task? \(movieListTask == nil) \(movies.last?.id == movieId) \(page) \(totalMoviePages)")
            if movies.last?.id == movieId,
               movieListTask == nil,
               page < totalMoviePages {
                print("-=- fech more.. \(page)")
                // fetch more.
                
                movieListTask = Task { [page] in
                    do  {
                        
                        let more = try await client.fetchPopluarList(page + 1)
                        switch self.movieListState {
                        case .loaded(.success(let oldMovies)):
                            self.movieListState = .loaded(.success(oldMovies + more.results))
                            self.page = more.page
                            print("-=- 1")
                        default:
                            print("-=- 1.1")
                            break
                        }
                    } catch {
                        print("-=- 1.2 \(error.localizedDescription)")
                    }
                    
                    movieListTask = nil
                }
            }
        }
                
    }
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ScrollView {
            if let errorString = viewModel.errorString {
                Text(errorString)
                    .foregroundStyle(.red)
            }
            
            if viewModel.isFetchPopluarListInFlight {
                ProgressView()
            } else {
                LazyVGrid(
                    columns: Array(repeating: .init(
                        .flexible(),
                        spacing: 0,
                        alignment: .leading
                    ), count: 3),
                    spacing: 0
                ) {
//                    viewModel.movies.enumerated()
                    ForEach(viewModel.movies, id: \.id) { movie in
                        VStack(spacing: 0) {
                            
                            movie.backdropPath.map {
                                AsyncImage(
                                    url: URL(string: imageURLPrefix + $0)
                                ) {
                                    image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(height: 100)
                                .background(.red)
                            }
                            
                            Button(action: {
                                viewModel.onMovieTapped(movie)
                            }, label: {
                                Text("\(movie.id): \(movie.originalTitle)")
                                    .frame(
                                        maxHeight: .infinity,
                                        alignment: .top
                                    )
                            })
                            .background(.orange)
                            
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                        .background(.purple)
                        .cornerRadius(15)
                        .onAppear {
                            viewModel.onMovieAppeared(movie.id)
                        }
                        
                    }
                }
                
            }
            
        }
        .onAppear {
            viewModel.onAppear()
        }
        .sheet(
            isPresented: $viewModel.presentedMovie.toBool(),
            content: {
                if let movie = viewModel.presentedMovie {
                    MovieDetailView(
                        movie: movie,
                        movieDetail: viewModel.movieDetailsCache[movie.id]
                    )
                }
            })
        .navigationTitle("Screen One")
    }
}


#Preview {
    NavigationStack {
        ContentView(
            viewModel: ContentView.ViewModel(
                client: .mock
                //            client: .live(apiKey: apiKey)
            )
        )
        
    }
}

private let threeColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

extension Binding {
    func toBool<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        Binding<Bool>(
            get: {
                self.wrappedValue != nil
            },
            set: { newValue in
                if !newValue {
                    self.wrappedValue = nil
                }
            }
        )
    }
}
