import UIKit

class GridColorView: UIView {
    
    let column = 12
    let row = 10
    var cellSize: CGSize {
        let length = bounds.width / Double(column)
        return CGSize(width: length, height: length)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.snp.makeConstraints { make in
            make.height.equalTo(self.snp.width).multipliedBy(10.0 / 12.0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func point(location: CGPoint) -> (x: Int, y: Int) {
        let x = Int(location.x / bounds.width * Double(column))
        let y = Int(location.y / bounds.height * Double(row))
        let clampedX = max(min(x, column - 1), 0)
        let clampedY = max(min(y, row - 1), 0)
        return (clampedX, clampedY)
    }
    
    func rect(forX x: Int, y: Int) -> CGRect {
        let x = Double(x) * cellSize.width
        let y = Double(y) * cellSize.height
        return CGRect(x: x, y: y, width: cellSize.width, height: cellSize.height).integral
    }
    
    func color(atX x: Int, y: Int) -> CGColor {
        let i = x + column * y
        return gridColors[i]
    }
    
    func index(forColor color: CGColor) -> Int? {
        gridColors.firstIndex(of: color)
    }
    
    func point(for index: Int) -> (x: Int, y: Int) {
        let x = index % column
        let y = index / column
        return (x, y)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let maskPath = UIBezierPath(roundedRect: rect, cornerRadius: 8).cgPath
        context.addPath(maskPath)
        context.clip()
        for (offset, color) in gridColors.enumerated() {
            context.setFillColor(color)
            let x = Double(offset % column) * cellSize.width
            let y = Double(offset / column) * cellSize.height
            let rect = CGRect(
                x: x,
                y: y,
                width: cellSize.width,
                height: cellSize.height
            ).integral
            context.fill(rect)
        }
    }
}

let gridColors = [
    CGColor.make(hue: 0.5, saturation: 1.7881391300989234e-07, brightness: 1.0000001192092896, alpha: 1.0),
    CGColor.make(hue: 0.0, saturation: 0.0, brightness: 0.9215685725212097, alpha: 1.0),
    CGColor.make(hue: 0.0, saturation: 0.0, brightness: 0.8392158150672913, alpha: 1.0),
    CGColor.make(hue: 0.6666666666666666, saturation: 2.350388746464036e-07, brightness: 0.7607845067977905, alpha: 1.0),
    CGColor.make(hue: 0.0, saturation: 0.0, brightness: 0.6784313917160034, alpha: 1.0),
    CGColor.make(hue: 0.0, saturation: 9.934103120361394e-08, brightness: 0.600000262260437, alpha: 1.0),
    CGColor.make(hue: 0.0, saturation: 0.0, brightness: 0.5215685963630676, alpha: 1.0),
    CGColor.make(hue: 0.0, saturation: 0.0, brightness: 0.43921566009521484, alpha: 1.0),
    CGColor.make(hue: 0.5, saturation: 8.260426806340572e-08, brightness: 0.36078429222106934, alpha: 1.0),
    CGColor.make(hue: 0.0, saturation: 0.0, brightness: 0.27843135595321655, alpha: 1.0),
    CGColor.make(hue: 0.0, saturation: 1.490116652292008e-07, brightness: 0.19999992847442627, alpha: 1.0),
    CGColor.make(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 1.0),
    CGColor.make(hue: 0.5427927479712105, saturation: 1.0000008528262967, brightness: 0.2901960015296936, alpha: 1.0),
    CGColor.make(hue: 0.6124030566718041, saturation: 0.9885061241912438, brightness: 0.34117642045021057, alpha: 1.0),
    CGColor.make(hue: 0.7037036449019883, saturation: 0.9152541596493883, brightness: 0.23137256503105164, alpha: 1.0),
    CGColor.make(hue: 0.7878787304369488, saturation: 0.9016391184547262, brightness: 0.2392156720161438, alpha: 1.0),
    CGColor.make(hue: 0.9371069428134492, saturation: 0.8833331750084862, brightness: 0.23529410362243652, alpha: 1.0),
    CGColor.make(hue: 0.010989057957337048, saturation: 0.9891304481945766, brightness: 0.3607843518257141, alpha: 1.0),
    CGColor.make(hue: 0.05185189759014103, saturation: 1.0, brightness: 0.3529411554336548, alpha: 1.0),
    CGColor.make(hue: 0.09659083584665185, saturation: 0.9999998953976554, brightness: 0.3450980484485626, alpha: 1.0),
    CGColor.make(hue: 0.11821714192184928, saturation: 0.9999999464825026, brightness: 0.3372547924518585, alpha: 1.0),
    CGColor.make(hue: 0.15849675674423808, saturation: 1.0000000601634467, brightness: 0.3999999463558197, alpha: 1.0),
    CGColor.make(hue: 0.17901242183708818, saturation: 0.9529411625336215, brightness: 0.3333333730697632, alpha: 1.0),
    CGColor.make(hue: 0.251773066273439, saturation: 0.7580645151405317, brightness: 0.24313727021217346, alpha: 1.0),
    CGColor.make(hue: 0.5396039537287965, saturation: 1.0000008768909685, brightness: 0.3960783779621124, alpha: 1.0),
    CGColor.make(hue: 0.6038250587740023, saturation: 0.9918705163572851, brightness: 0.4823530316352844, alpha: 1.0),
    CGColor.make(hue: 0.70370370736863, saturation: 0.8780487915074382, brightness: 0.32156866788864136, alpha: 1.0),
    CGColor.make(hue: 0.7894736697376187, saturation: 0.8539325540478288, brightness: 0.3490196168422699, alpha: 1.0),
    CGColor.make(hue: 0.9396135337530311, saturation: 0.8117645157610216, brightness: 0.33333325386047363, alpha: 1.0),
    CGColor.make(hue: 0.021628530592802803, saturation: 0.9999999882887997, brightness: 0.5137256383895874, alpha: 1.0),
    CGColor.make(hue: 0.055555580969049924, saturation: 1.0000000124729072, brightness: 0.48235297203063965, alpha: 1.0),
    CGColor.make(hue: 0.10109286933665908, saturation: 0.9999999748497148, brightness: 0.47843146324157715, alpha: 1.0),
    CGColor.make(hue: 0.12222222335864279, saturation: 1.000000025569463, brightness: 0.47058820724487305, alpha: 1.0),
    CGColor.make(hue: 0.15827336586688026, saturation: 0.9858157187434481, brightness: 0.5529412627220154, alpha: 1.0),
    CGColor.make(hue: 0.17746915992311993, saturation: 0.9152541809352239, brightness: 0.4627450704574585, alpha: 1.0),
    CGColor.make(hue: 0.25136610736877857, saturation: 0.7011494210201782, brightness: 0.34117642045021057, alpha: 1.0),
    CGColor.make(hue: 0.5387323517100489, saturation: 0.9930080866109633, brightness: 0.5607842803001404, alpha: 1.0),
    CGColor.make(hue: 0.6015778195462336, saturation: 1.0000007195843172, brightness: 0.6627451181411743, alpha: 1.0),
    CGColor.make(hue: 0.7196969772860949, saturation: 0.924369715968098, brightness: 0.46666663885116577, alpha: 1.0),
    CGColor.make(hue: 0.7883332951770342, saturation: 0.8064513830768348, brightness: 0.48627448081970215, alpha: 1.0),
    CGColor.make(hue: 0.9385965164898705, saturation: 0.7851238796099211, brightness: 0.4745098948478699, alpha: 1.0),
    CGColor.make(hue: 0.0239411190217572, saturation: 1.0000000678085035, brightness: 0.7098040580749512, alpha: 1.0),
    CGColor.make(hue: 0.05973023959331886, saturation: 1.000000124152243, brightness: 0.6784316897392273, alpha: 1.0),
    CGColor.make(hue: 0.10256412065218189, saturation: 1.000000363116525, brightness: 0.6627452373504639, alpha: 1.0),
    CGColor.make(hue: 0.1232323195700626, saturation: 0.9939758981159517, brightness: 0.650980532169342, alpha: 1.0),
    CGColor.make(hue: 0.1598639870090778, saturation: 1.0000003130954314, brightness: 0.7686274647712708, alpha: 1.0),
    CGColor.make(hue: 0.1777042212856135, saturation: 0.9151518034335042, brightness: 0.6470589637756348, alpha: 1.0),
    CGColor.make(hue: 0.2550201108417376, saturation: 0.680327868852459, brightness: 0.4784313440322876, alpha: 1.0),
    CGColor.make(hue: 0.5370369963349069, saturation: 1.0000016055986614, brightness: 0.7058824896812439, alpha: 1.0),
    CGColor.make(hue: 0.5996883662976177, saturation: 1.0000011954316548, brightness: 0.8392159342765808, alpha: 1.0),
    CGColor.make(hue: 0.7062840808636683, saturation: 0.8243243760198469, brightness: 0.5803924202919006, alpha: 1.0),
    CGColor.make(hue: 0.7853332812913322, saturation: 0.7911391564858609, brightness: 0.6196079850196838, alpha: 1.0),
    CGColor.make(hue: 0.9387464637286486, saturation: 0.7647060255209122, brightness: 0.6000002026557922, alpha: 1.0),
    CGColor.make(hue: 0.026548719683155825, saturation: 1.0, brightness: 0.8862747550010681, alpha: 1.0),
    CGColor.make(hue: 0.06192660126016053, saturation: 0.9999999437002847, brightness: 0.8549022078514099, alpha: 1.0),
    CGColor.make(hue: 0.10317461552465218, saturation: 0.9952608051213885, brightness: 0.8274512887001038, alpha: 1.0),
    CGColor.make(hue: 0.12500006491413254, saturation: 0.9952153346469477, brightness: 0.8196078538894653, alpha: 1.0),
    CGColor.make(hue: 0.16054420872054925, saturation: 1.0000001001905363, brightness: 0.960784375667572, alpha: 1.0),
    CGColor.make(hue: 0.17921145091729618, saturation: 0.8899523781958192, brightness: 0.8196079134941101, alpha: 1.0),
    CGColor.make(hue: 0.25396832979180484, saturation: 0.6687899855801416, brightness: 0.6156864762306213, alpha: 1.0),
    CGColor.make(hue: 0.5424381658507835, saturation: 1.0000024164743258, brightness: 0.8470590710639954, alpha: 1.0),
    CGColor.make(hue: 0.6030182450295308, saturation: 1.0000013757817203, brightness: 0.9960786700248718, alpha: 1.0),
    CGColor.make(hue: 0.7164350938063769, saturation: 0.8089887602072519, brightness: 0.6980394721031189, alpha: 1.0),
    CGColor.make(hue: 0.792237438644127, saturation: 0.7765956010489053, brightness: 0.7372549176216125, alpha: 1.0),
    CGColor.make(hue: 0.942857191453167, saturation: 0.756756672378546, brightness: 0.725490391254425, alpha: 1.0),
    CGColor.make(hue: 0.030626817400354667, saturation: 0.9176472892654947, brightness: 1.0000004768371582, alpha: 1.0),
    CGColor.make(hue: 0.06928101712514867, saturation: 0.9999999518692663, brightness: 1.0000003576278687, alpha: 1.0),
    CGColor.make(hue: 0.11154862134345682, saturation: 0.996078883529686, brightness: 0.9999999403953552, alpha: 1.0),
    CGColor.make(hue: 0.13109358374784674, saturation: 1.0000008732019892, brightness: 0.9921570420265198, alpha: 1.0),
    CGColor.make(hue: 0.16402123231343096, saturation: 0.7440947136465024, brightness: 0.9960785508155823, alpha: 1.0),
    CGColor.make(hue: 0.18416199116812645, saturation: 0.766949167551622, brightness: 0.9254902005195618, alpha: 1.0),
    CGColor.make(hue: 0.2601626706949007, saturation: 0.6577542182392249, brightness: 0.7333336472511292, alpha: 1.0),
    CGColor.make(hue: 0.5351924769687332, saturation: 0.9960349052498567, brightness: 0.9882356524467468, alpha: 1.0),
    CGColor.make(hue: 0.6011904168764146, saturation: 0.7716540604222488, brightness: 0.9960786700248718, alpha: 1.0),
    CGColor.make(hue: 0.7076648281746114, saturation: 0.7957445323683123, brightness: 0.9215686321258545, alpha: 1.0),
    CGColor.make(hue: 0.7860962469773672, saturation: 0.7695471951161464, brightness: 0.952941358089447, alpha: 1.0),
    CGColor.make(hue: 0.9385965200764304, saturation: 0.7434781126128713, brightness: 0.9019607901573181, alpha: 1.0),
    CGColor.make(hue: 0.017142900569100932, saturation: 0.6862745098039216, brightness: 0.9999999403953552, alpha: 1.0),
    CGColor.make(hue: 0.05646636689113841, saturation: 0.7176471184281777, brightness: 0.9999999403953552, alpha: 1.0),
    CGColor.make(hue: 0.10209428791720059, saturation: 0.7519686083024039, brightness: 0.9960785508155823, alpha: 1.0),
    CGColor.make(hue: 0.12239579808133054, saturation: 0.7559055848432333, brightness: 0.9960786700248718, alpha: 1.0),
    CGColor.make(hue: 0.15765764054145798, saturation: 0.5803920530805524, brightness: 1.0000001192092896, alpha: 1.0),
    CGColor.make(hue: 0.1799517216814521, saturation: 0.577406001959995, brightness: 0.9372550249099731, alpha: 1.0),
    CGColor.make(hue: 0.25431038050242666, saturation: 0.5497631593202523, brightness: 0.827451229095459, alpha: 1.0),
    CGColor.make(hue: 0.537254809047739, saturation: 0.6746037370572461, brightness: 0.9882352948188782, alpha: 1.0),
    CGColor.make(hue: 0.6055155517366889, saturation: 0.5450984024532306, brightness: 1.0000004768371582, alpha: 1.0),
    CGColor.make(hue: 0.7190475776893185, saturation: 0.6889765381524225, brightness: 0.9960787892341614, alpha: 1.0),
    CGColor.make(hue: 0.7904191582250536, saturation: 0.6574803764490461, brightness: 0.9960785508155823, alpha: 1.0),
    CGColor.make(hue: 0.939999974870691, saturation: 0.5252101398458714, brightness: 0.9333335757255554, alpha: 1.0),
    CGColor.make(hue: 0.013333326848350757, saturation: 0.49019611232419763, brightness: 1.0000003576278687, alpha: 1.0),
    CGColor.make(hue: 0.051282130725497, saturation: 0.5098040092225063, brightness: 1.0000001192092896, alpha: 1.0),
    CGColor.make(hue: 0.09803922773867964, saturation: 0.5333334763844637, brightness: 1.0000001192092896, alpha: 1.0),
    CGColor.make(hue: 0.1200981457699638, saturation: 0.533333273728685, brightness: 0.9999999403953552, alpha: 1.0),
    CGColor.make(hue: 0.15732100768492188, saturation: 0.41960754511401327, brightness: 0.9999999403953552, alpha: 1.0),
    CGColor.make(hue: 0.18013468013468015, saturation: 0.4090908833973217, brightness: 0.9490196108818054, alpha: 1.0),
    CGColor.make(hue: 0.25609755645473703, saturation: 0.37104089700752885, brightness: 0.866666853427887, alpha: 1.0),
    CGColor.make(hue: 0.5408805631153158, saturation: 0.41897235148702366, brightness: 0.9921570420265198, alpha: 1.0),
    CGColor.make(hue: 0.6079544335804926, saturation: 0.34509829399626396, brightness: 1.000000238418579, alpha: 1.0),
    CGColor.make(hue: 0.7207602261212736, saturation: 0.4488187511021653, brightness: 0.9960784316062927, alpha: 1.0),
    CGColor.make(hue: 0.7901234689522482, saturation: 0.42519684285489207, brightness: 0.9960786700248718, alpha: 1.0),
    CGColor.make(hue: 0.9416667521620515, saturation: 0.327868874924884, brightness: 0.9568629860877991, alpha: 1.0),
    CGColor.make(hue: 0.012500060955054551, saturation: 0.31372549370223357, brightness: 1.0000001192092896, alpha: 1.0),
    CGColor.make(hue: 0.05158725060740962, saturation: 0.329411646197838, brightness: 1.0000001192092896, alpha: 1.0),
    CGColor.make(hue: 0.09386977899068315, saturation: 0.3411766858661106, brightness: 1.0000003576278687, alpha: 1.0),
    CGColor.make(hue: 0.11627908757791054, saturation: 0.33858269554120063, brightness: 0.9960786700248718, alpha: 1.0),
    CGColor.make(hue: 0.1571427485772477, saturation: 0.2745097221112914, brightness: 1.000000238418579, alpha: 1.0),
    CGColor.make(hue: 0.1796876979060589, saturation: 0.2591092479635712, brightness: 0.9686276316642761, alpha: 1.0),
    CGColor.make(hue: 0.25490218284078053, saturation: 0.21982757971200304, brightness: 0.9098041653633118, alpha: 1.0),
    CGColor.make(hue: 0.5480766513953915, saturation: 0.20392168783674763, brightness: 0.9999999403953552, alpha: 1.0),
    CGColor.make(hue: 0.6098484102658345, saturation: 0.17254924563792504, brightness: 1.0000003576278687, alpha: 1.0),
    CGColor.make(hue: 0.7169811176464402, saturation: 0.20866141473136915, brightness: 0.9960786700248718, alpha: 1.0),
    CGColor.make(hue: 0.7830187678231804, saturation: 0.2078432541267266, brightness: 1.000000238418579, alpha: 1.0),
    CGColor.make(hue: 0.9429824333345467, saturation: 0.1526103434642695, brightness: 0.9764707684516907, alpha: 1.0),
    CGColor.make(hue: 0.012820472848875886, saturation: 0.1529408784473466, brightness: 0.9999999403953552, alpha: 1.0),
    CGColor.make(hue: 0.048780160794964056, saturation: 0.16078430624569431, brightness: 1.0000003576278687, alpha: 1.0),
    CGColor.make(hue: 0.09302321060268388, saturation: 0.16862721256179886, brightness: 0.9999999403953552, alpha: 1.0),
    CGColor.make(hue: 0.11507934641066886, saturation: 0.16470579329660018, brightness: 1.0000001192092896, alpha: 1.0),
    CGColor.make(hue: 0.15656596827209907, saturation: 0.1299212963586289, brightness: 0.9960785508155823, alpha: 1.0),
    CGColor.make(hue: 0.18279546168446933, saturation: 0.12399993166446693, brightness: 0.9803921580314636, alpha: 1.0),
    CGColor.make(hue: 0.262820554041159, saturation: 0.10924372645843321, brightness: 0.9333335757255554, alpha: 1.0),
]
