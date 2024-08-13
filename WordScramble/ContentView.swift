//
//  ContentView.swift
//  WordScramble
//
//  Created by Ricardo on 04/08/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var useWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView{
            VStack {
                List{
                    
                    Section{
                        TextField("Enter your word", text: $newWord).textInputAutocapitalization(.never)
                    }
                    
                    Section{
                        ForEach(useWords, id: \.self){
                            word in
                            HStack{
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                            .accessibilityElement()
                            .accessibilityLabel(word)
                            .accessibilityHint("\(word.count) letters")
                        }
                    }
                    
                }
                .navigationTitle(rootWord)
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
                .toolbar{
                    ToolbarItem(placement: .bottomBar) {
                        Button("New Word") {
                            startGame()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow) // Set the star color
                                .font(.system(size: 20)) // Adjust the star size
                            Text("Score: \(score)")
                                .font(.headline) // Use a headline font
                                .foregroundColor(.primary) // Use primary text color
                        }
                    }
                }
                .alert(errorTitle,isPresented: $showingError){
                    Button("OK", role:.cancel){}
                }
                message: {
                Text(errorMessage)
                }

        }
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // isempty would have been easier but we are doing this bc we want to limit the min word size
        
        guard answer.count > 2 && answer != rootWord else {return}
        
        // extra validation
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't make them up")
            return
        }

        
        withAnimation{
            useWords.insert(answer, at: 0)
        }
        
        withAnimation{
            score += 100
        }
        
        newWord = ""
    }
    
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                useWords.removeAll()
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !useWords.contains(word)
    }
    
    func isPossible(word:String)->Bool{
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else {
                return false
            }
        }
        return true
        }
    
    func isReal(word:String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
        
    }
    
    func wordError(title:String, message:String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }

    
}
    


#Preview {
    ContentView()
}
