import QtQuick 2.3
import QtGraphicalEffects 1.0
import "Scene"

Item {
    id: root
    width: 1280
    height: 720
    property int phase: 0 // phases : 0-start 1-position 2-angle 3-power 4-sweeping 5-score 6-winner
    property int position_evo: 1
    property double power: 0
    property int power_evo: 1
    property double power_gap: 1
    property double angle: -20
    property int angle_evo: 1
    property double angle_gap: 0.4
    property double angle_max: 25
    property double angle_rad: angle * Math.PI / 180
    property int current_pierre: 0
    property bool ready: false

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#ddddee"
    }

    Piste {
        id: piste
        anchors.centerIn: parent
    }

    Hud {
        id: hud
        power: root.power
        angle: root.angle
        phase: root.phase
        opacity: 0.8
    }

    Item{
        id: traces
        anchors.fill: parent
        function clear(){
            var nt = traces.children.length
            for (var t = nt - 1; t >= 0; t--){
                traces.children[t].destroy()
            }
        }
    }

    Pierres {
        id: pierres
    }
    property alias pierre: pierres.current

    Launcher{
        id: launcher
        xC: root.phase > 3 ? piste.x + piste.start_line + 20 : pierre.xC - 3 * pierre.width / 4
        yC: root.phase > 3 ? piste.y + piste.height / 2 - pierre.height / 3 : pierre.yC - pierre.height / 3
        color: pierre.main_color
    }

    Sweeper {
        id: sweeper_1
        xC: root.phase > 3 ? (root.phase == 4 ? pierre.xC + x1_gap(pierre.width + 4, pierre.height + 5, pierre.angle_rad) : piste.x + 1100) : piste.x + 200
        yC: root.phase > 3 ? (root.phase == 4 ? pierre.yC + y1_gap(pierre.width + 4, pierre.height + 5, pierre.angle_rad) : piste.y + piste.height + 40) : piste.y + piste.height - 20
        transform: Rotation {
            origin.x: sweeper_1.width / 2
            origin.y: sweeper_1.height / 2
            angle: root.phase > 3 ? pierre.angle : 0
        }
        color: pierre.main_color
    }
    function x1_gap(ax, ay, angle) {
        return ax * Math.cos(angle) - ay * Math.sin(angle)
    }
    function y1_gap(ax, ay, angle) {
        return ax * Math.sin(angle) + ay * Math.cos(angle)
    }

    Sweeper {
        id: sweeper_2
        xC: root.phase > 3 ? (root.phase == 4 ? pierre.xC + x2_gap(pierre.width + 15, pierre.height + 5, pierre.angle_rad) : piste.x + 1100) : piste.x + 200
        yC: root.phase > 3 ? (root.phase == 4 ? pierre.yC + y2_gap(pierre.width + 15, pierre.height + 5, pierre.angle_rad) : piste.y - 40 ) : piste.y + 20
        transform: Rotation {
            origin.x: sweeper_2.width / 2
            origin.y: sweeper_2.height / 2
            angle: (root.phase > 3 ? pierre.angle : 0) + 180
        }
        color: pierre.main_color
    }
    function x2_gap(ax, ay, angle) {
        return ax * Math.cos(angle) + ay * Math.sin(angle)
    }
    function y2_gap(ax, ay, angle) {
        return ax * Math.sin(angle) - ay * Math.cos(angle)
    }

    Controls {
        id: controls
        onRestart: {
            root.restart()
        }
        onPressSpace: {
            switch(root.phase) {
            case 1:
                root.phase = 2
                break
            case 2:
                root.phase = 3
                break
            case 3:
                root.phase = 4
                break
            }
        }
        onPressUp: {
            switch(root.phase) {
            case 1:
                pierre.move_up = true
                break
            case 4:
                sweeper_2.sweep()
                pierre.angle = pierre.angle + 0.12
                pierre.speed = pierre.speed + 0.005
                break
            }
        }
        onPressDown: {
            switch(root.phase) {
            case 1:
                pierre.move_down = true
                break
            case 4:
                sweeper_1.sweep()
                pierre.angle = pierre.angle - 0.12
                pierre.speed = pierre.speed + 0.005
                break
            }
        }
        onReleaseUp: {
            switch(root.phase) {
            case 1:
                pierre.move_up = false
                break
            }
        }
        onReleaseDown: {
            switch(root.phase) {
            case 1:
                pierre.move_down = false
                break
            }
        }
    }

    function update() {
        switch(phase) {
        case 0:
            root.phase0_update()
            break
        case 1:
            root.phase1_update()
            break
        case 2:
            root.phase2_update()
            break
        case 3:
            root.phase3_update()
            break
        case 4:
            root.phase4_update()
            break
        case 5:
            root.phase5_update()
            break
        case 6:
            root.phase6_update()
            break
        }
    }

    onPhaseChanged: {
        switch(phase) {
        case 3:
            pierre.angle = root.angle
            break
        case 4:
            launcher.move_smooth()
            sweeper_1.move_smooth()
            sweeper_2.move_smooth()
            if (root.power > 60)
                pierre.speed = root.power / 30
            else
                pierre.speed = 2
            pierre.f_curl_dir = root.angle > 0 ? -1 : 1
            pierre.f_curl = 0.05
            break
        case 5:
            sweeper_1.move_smooth()
            sweeper_2.move_smooth()
            break
        }
    }

    function phase0_update() {
        if (!root.ready)
            root.initialize(root.current_pierre)
        root.phase = 1
    }

    function phase1_update() {
        pierre.update_phase1(piste)
    }

    function phase2_update() {
        pierre.custom_move(0.5 - Math.random() * 0.3, 0)
        root.update_angle()
        if (pierre.xC > piste.x + piste.start_line)
            root.phase = 4
    }

    function phase3_update() {
        pierre.custom_move(0.5 - Math.random() * 0.3, pierre.angle)
        root.update_power()
        if (pierre.xC > piste.x + piste.start_line)
            root.phase = 4
    }

    function phase4_update() {
        pierres.update()
        collisions()
        if (pierre.xC > piste.x + piste.end_sweep_line || pierres.immobile())
            root.phase = 5
    }

    function phase5_update() {
        pierres.update()
        collisions()
        if (pierres.immobile()) {
            root.score()
            if (root.current_pierre == 15){
                root.phase = 6
                hud.show_winner()
            }
            else{
                root.current_pierre = (root.current_pierre + 1) % 16
                root.ready = false
                root.phase = 0
            }
        }
    }

    function phase6_update() {
    }

    function update_angle() {
        var new_angle = root.angle + angle_evo * (angle_gap + 0.1 * (root.angle_max - Math.abs(root.angle)))
        if (new_angle >= root.angle_max) {
            root.angle_evo = -1
            if (angle_gap < 0.8)
                root.angle_gap = root.angle_gap + 0.2
            root.angle = root.angle_max
        }
        else if (new_angle <= -root.angle_max) {
            root.angle_evo = 1
            root.angle = -root.angle_max
        }
        else
            root.angle = new_angle
    }

    function update_power() {
        var new_power = root.power + power_evo * (power_gap + 0.05 * root.power)
        if (new_power >= 100) {
            root.power_evo = -1
            if (power_gap < 7)
                root.power_gap = root.power_gap + 1
            root.power = 100
        }
        else if (new_power <= 0) {
            root.power_evo = 1
            root.power = 0
        }
        else
            root.power = new_power
    }

    function initialize(n) {
        pierres.current_n = n
        root.position_evo = 1
        root.phase = 0
        root.power = 0
        root.power_evo = 1
        root.power_gap = 1
        root.angle = -20
        root.angle_evo = 1
        root.angle_gap = 1
        if ( n === 0)
            pierres.initialize(piste)
        pierre.xC = piste.x + 20
        pierre.yC = piste.y + piste.height / 2
        root.ready = true
    }

    function restart(){
        traces.clear()
        hud.initialize()
        root.current_pierre = 0
        root.ready = false
        root.phase = 0
    }

    function score() {
        var scores = [0, 0]
        var dmax = piste.r_target + pierre.radius
        var array = []
        var k = 0
        for (var i = 0; i < pierres.max; i++){
            var d = d2_target(pierres.children[i].xC, pierres.children[i].yC)
            if (d < dmax * dmax){
                array[k] = [i, d]
                k ++
            }
        }
        array.sort(compare)
        if (array.length > 0){
            var t = pierres.children[array[0][0]].team
            scores[t] = 1
            for (i = 1; i < array.length; i++){
                if (pierres.children[array[i][0]].team === t)
                    scores[t] ++
                else
                    break
            }
        }
        hud.score0 = scores[0]
        hud.score1 = scores[1]
    }

    function compare(a, b) {
        if (a[1] === b[1]) {
            return 0
        }
        else {
            return (a[1] < b[1]) ? -1 : 1
        }
    }

    function collisions() {
        for (var i = 0; i < 16; i++) {
            for (var j = i + 1; j < 16; j++) {
                var d = d2(pierres.children[i].xC, pierres.children[i].yC, pierres.children[j].xC, pierres.children[j].yC)
                if (d < (2 * pierre.radius) * (2 * pierre.radius)){
                    var a = root.slope(pierres.children[i].xC, pierres.children[i].yC, pierres.children[j].xC, pierres.children[j].yC)
                    var a1 = pierres.children[i].angle
                    var a2 = pierres.children[j].angle
                    var s1 = pierres.children[i].speed
                    var s2 = pierres.children[j].speed
                    var th1rad = (a1 - a - 90) * Math.PI / 180
                    var th2rad = (a2 - a - 90) * Math.PI / 180
                    var cs11 = s1 * Math.cos(th1rad)
                    var cs12 = s2 * Math.sin(th2rad)
                    var cs21 = s1 * Math.sin(th1rad)
                    var cs22 = s2 * Math.cos(th2rad)
                    pierres.children[i].speed = Math.sqrt(cs11 * cs11 + cs12 * cs12)
                    pierres.children[j].speed = Math.sqrt(cs21 * cs21 + cs22 * cs22)
                    pierres.children[i].angle = Math.atan2(cs12, cs11) * 180 / Math.PI + (a + 90)
                    pierres.children[j].angle = Math.atan2(cs21, cs22) * 180 / Math.PI + (a + 90)
                }
            }
        }
    }

    function d2(x0, y0, x1, y1) {
        return (x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0)
    }

    function d2_target(xc, yc) {
        var xt = piste.x + piste.x_target
        var yt = piste.y + piste.y_target
        return d2(xc, yc, xt, yt)
    }

    function slope(x0, y0, x1, y1) {
        var a = Math.atan2(y1 - y0, x1 - x0)
        return a / Math.PI * 180
    }
}
