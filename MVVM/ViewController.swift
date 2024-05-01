//
//  ViewController.swift
//  MVVM
//
//  Created by Paramitha on 30/04/24.
//

import Kingfisher
import Moya
import RxCocoa
import RxSwift
import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionCell
        cell.imageView.kf.setImage(with: URL(string: data[indexPath.row].image))
        cell.titleLabel.text = data[indexPath.row].name
        return cell
    }

    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 160, height: 160)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 20
        flowLayout.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        return collection
    }()

    let viewModel = ViewModel()
    var data = [Pokemon]()
    
    let loadTrigger = PublishSubject<Void>()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTrigger.onNext(())
    }

    func setupCollectionView() {
        view.backgroundColor = .blue
        collectionView.backgroundColor = .green
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])
        
        
        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupViewModel() {
        let input = ViewModel.Input(loadDataTrigger: loadTrigger.asDriver(onErrorDriveWith: .just(())))
        let output = viewModel.transform(input: input)
        
        output.data.drive(onNext: { pokemon in
            self.data = pokemon
            self.collectionView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == data.count - 1 ) { //it's your last cell
            loadTrigger.onNext(())
        }
    }

}

