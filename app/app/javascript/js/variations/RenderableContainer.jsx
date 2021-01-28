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

            shift: 0,
            resetShift: this.props.resetShift,
            busy: false
        };

    }


    /* returns false if no intersection
     * otherwise for rectA: maxArea, equalArea, minArea -> 1,0,-1
     */
    intersect(rectA, rectB) {

        const val = !(rectB.left > rectA.right ||
                      rectB.right < rectA.left ||
                      rectB.top > rectA.bottom ||
                      rectB.bottom < rectA.top);

        if (val === false) return false;
        if (val == true) {
            //maxArea
            const areaA = rectA.width * rectA.height
            const areaB = rectB.width * rectB.height
            if (areaA > areaB) return -1;
            if (areaA < areaB) return 1;
        }
        return 0;
    }

    contains(rectA, rectB) {

        if (rectA.x < rectB.x && rectA.y < rectB.y) {
            if ( rectA.x + rectA.width < rectB.x + rectB.width &&
                 rectA.y + rectA.height < rectB.y + rectB.height)
                return -1;
        }
        return false;
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

        const rects = this.props.diffs.sort( (diffA, diffB) => {
            const dimA = this.state.isControl ? diffA.origDim : diffA.newDim;
            const dimB = this.state.isControl ? diffB.origDim : diffB.newDim;

            //calc sort order, want larger, containg rects to be rendered first
            //so subsequent smaller, contained rects have a higher paint order
            //and are clickable. Effectively sorting for z-index.

            if (!dimA.boundingBox && !dimB.boundingBox) return 0;
            if (dimA.boundingBox && !dimB.boundingBox) return -1;
            if (!dimA.boundingBox && dimB.boundingBox) return 1;

            //contains - return the contained
            const contains = this.contains(dimA.boundingBox.rect, dimB.boundingBox.rect);
            if (contains === -1) return -1;

            //intersection - greater area first, smaller area later
            //since ascending: if areaA > areaB, return -1 -> areaA will come before areaB
            const intersect = this.intersect(dimA.boundingBox.rect, dimB.boundingBox.rect);
            if (intersect !== false) return intersect;

            //base return y ascending (small -> big)
            return (dimA.boundingBox.rect.y == dimB.boundingBox.rect.y) ? 0 :
                   dimA.boundingBox.rect.y > dimB.boundingBox.rect.y ? 1 : -1;

        }).map( diff => {
            return <BoundingBox key={diff.id}
                                diff={diff}
                                isControl={this.state.isControl}
                                diffBboxHoverId={this.props.diffBboxHoverId}
                                {...this.props}
                   />;
        })

        return(
            <svg style={svgStyle} className="svg"
                 viewBox={`0 0 ${this.state.imgWidth} ${this.state.imgHeight}`}
                 xmlns="http://www.w3.org/2000/svg">
                {rects}
            </svg>
        )
    }



    renderableScrollHandler(deltaY) {
        console.log("rcScroll", deltaY);

        //deltaY value is inconsistent across browsers, can only rely
        //on direction
        const normDeltaY = deltaY > 0 ? 1 : -1;
        const deltaYScrollFactor = 120;

        if (!this.state.busy) {
            setTimeout(() => {

                this.setState({
                    shift: this.state.shift + (normDeltaY * deltaYScrollFactor),
                    busy: false
                });

            }, 100);
        }

        this.setState({ busy: true});
    }

    componentDidUpdate(prevProps) {
        //if resetShift is triggered externally, the prop will increment
        //indicating a reset compared to previous prop.
        //Otherwise additional re-renders are tied to setState, so props don't change.
        //example of when you need props to update an internal component state
        if(this.props.resetShift != prevProps.resetShift) {
            console.log('reset shift')
            this.setState({shift:0})
        }
    }

    render() {

        let marginTop = '0px'
        if (this.state.shift) {
            marginTop = `${-this.state.shift}px`
        }

        const wrapStyle = {
            position: 'relative',
            //fixes svg size
            padding: 0,
            margin: '.75rem',
            transition: 'margin 400ms ease-out 0s',
            marginTop,
            display: this.props.isVisible ? 'block' : 'none'
        };

        const isHidden = this.state.isControl ?
                         "is-hidden-touch is-hidden-desktop-only" : "";

        return(
            <div className={`column ${isHidden}`} style={wrapStyle}>
                <h4>{this.props.label}</h4>

                <RenderableScroll
                    scrollListener = {this.renderableScrollHandler.bind(this)}
                    {...this.props}>

                    { this.drawSVGRects() }

                </RenderableScroll>

                <Img {...this.props} />
            </div>
        )
    }
}
