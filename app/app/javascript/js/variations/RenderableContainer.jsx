import React from 'react';
import ReactDOM from 'react-dom';
import BoundingBox from './BoundingBox.jsx';
import Img from './Img.jsx';
import RenderableScroll from './RenderableScroll.jsx'

export default class RenderableContainer extends React.Component {

    constructor(props) {
        super(props);
        console.log("RenderableContainer", this.props.renderable.control);

        this.state = {
            isControl: this.props.renderable.control,

            imgWidth: this.props.renderable.screenshotWidth,
            imgHeight: this.props.renderable.screenshotHeight,

            shift: 0
        };

    }


    drawSVGRects() {

        const svgStyle = {
            position: 'absolute',
            zIndex:10, //need to be on top
            display: this.props.bboxVisible ? 'block' : 'none',
            visibility: this.props.bboxVisible ? 'visible' : 'hidden',
            maxWidth: this.state.imgWidth,
            maxHeight: this.state.imgHeight
        };

        const rects = this.props.diffs.map( diff => {
            return <BoundingBox key={diff.id}
                                diff={diff}
                                isControl={this.state.isControl}
                                diffBboxHoverId={this.props.diffBboxHoverId}
                                {...this.props}
                   />;
        });

        return(

            <RenderableScroll {...this.props} >

                <svg style={svgStyle} className="svg"
                     viewBox={`0 0 ${this.state.imgWidth} ${this.state.imgHeight}`}
                     xmlns="http://www.w3.org/2000/svg">
                    {rects}
                </svg>

            </RenderableScroll>
        )
    }

    render() {

        const wrapStyle = {
            position: 'relative',
            //fixes svg size
            padding: 0,
            margin: '.75rem',
            marginTop: this.props.shift ? `${-this.props.shift}px` : '0px',
            transition: 'margin 400ms ease-out 0s'
            //overflowY: 'scroll'
        };

        const isHidden = this.state.isControl ?
                         "is-hidden-touch is-hidden-desktop-only" : "";

        return(
            <div className={`column ${isHidden}`} style={wrapStyle}>
                <h4>{this.props.label}</h4>

                { this.drawSVGRects() }

                <Img {...this.props} />
            </div>
        )
    }
}
