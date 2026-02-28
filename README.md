# Glasses

Directory structure:
└── lucalangella-glasses/
    ├── README.md
    ├── LensCoatingsView.swift
    ├── LensSelectionView.swift
    ├── LensVisualizationView.swift
    ├── LICENSE
    ├── PrescriptionGuideView.swift
    └── Glasses/
        ├── GlassesApp.swift
        ├── Assets.xcassets/
        │   ├── Contents.json
        │   ├── AccentColor.colorset/
        │   │   └── Contents.json
        │   ├── AppIcon.appiconset/
        │   │   └── Contents.json
        │   └── frames/
        │       ├── Contents.json
        │       ├── aviator.imageset/
        │       │   └── Contents.json
        │       ├── Browline.imageset/
        │       │   └── Contents.json
        │       ├── cateye.imageset/
        │       │   └── Contents.json
        │       ├── geometric.imageset/
        │       │   └── Contents.json
        │       ├── oval.imageset/
        │       │   └── Contents.json
        │       ├── oversized.imageset/
        │       │   └── Contents.json
        │       ├── rectangle.imageset/
        │       │   └── Contents.json
        │       ├── round.imageset/
        │       │   └── Contents.json
        │       └── square.imageset/
        │           └── Contents.json
        ├── Extensions/
        │   └── View+Extensions.swift
        ├── Models/
        │   └── Prescription.swift
        ├── Utilities/
        │   └── PDCalculator.swift
        ├── ViewModels/
        │   ├── FaceScannerViewModel.swift
        │   └── OptometryViewModel.swift
        └── Views/
            ├── ARFeatures/
            │   ├── FaceScannerView.swift
            │   ├── PDMeasurementView.swift
            │   └── Scanner/
            │       ├── ARFaceTrackingEngine.swift
            │       ├── IntroSheetView.swift
            │       └── ResultsSheetView.swift
            ├── Components/
            │   ├── FramesGridView.swift
            │   └── PrescriptionTableView.swift
            ├── CustomControls/
            │   ├── AxisRulerScaleView.swift
            │   ├── ProtractorView.swift
            │   └── VisualRulerScaleView.swift
            ├── Representables/
            │   └── ImagePicker.swift
            └── Screens/
                ├── ContentView.swift
                └── Glasses3DView.swift
