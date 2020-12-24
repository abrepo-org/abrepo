import React from 'react';
import ReactDOM from 'react-dom';
import BoundingBox from './BoundingBox.jsx';
import Img from './Img.jsx';

export default class RenderableContainer extends React.Component {

    constructor(props) {
        super(props);
        console.log("RenderableContainer", this.props.renderable.control);

        this.state = {
            isControl: this.props.renderable.control,
            bboxVisible: true,
            //TDOO:replace
            imgWidth: this.props.renderable.screenshotWidth,
            imgHeight: this.props.renderable.screenshotHeight
        };
    }


    drawSVGRects() {
        const svgStyle = {
            position: 'absolute',
            zIndex:10, //need to be on top
            display: this.state.bboxVisible ? 'block' : 'none',
            visibility: this.state.bboxVisible ? 'visible' : 'hidden'
        };

        const rects = this.props.diffs.map( diff => {
            return <BoundingBox key={diff.id}
                                diff={diff}
                                isControl={this.state.isControl} />;
        });

        return(
            <svg style={svgStyle} className="svg"
                 onClick={() => this.imgClickHandler()}
                 viewBox={`0 0 ${this.state.imgWidth} ${this.state.imgHeight}`}
                 xmlns="http://www.w3.org/2000/svg">
                {rects}
            </svg>
        )

    }

    //handler: click img toggle on/off bbox
    //TODO: need to lift up, currently sets individual renderable
    imgClickHandler(isControl) {
        console.log("imgClick");
        this.setState({
            bboxVisible: !this.state.bboxVisible
        });
    }

    render() {

        const wrapStyle = {
            position: 'relative',
            //fixes svg size
            padding: 0,
            margin: '.75rem'
        };

        return(
            <div className="column" style={wrapStyle}>
                <h4>Renderable</h4>

                { this.drawSVGRects() }

                <Img imgClickHandler={this.imgClickHandler.bind(this)}
                     bboxVisible = {this.state.bboxVisible}
                     {...this.props} />
            </div>
        )
    }
}
