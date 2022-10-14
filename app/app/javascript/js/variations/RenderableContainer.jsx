import React from 'react';
import ReactDOM from 'react-dom';
import DiffBoundingBox from './boundingBox/DiffBoundingBox.jsx';
import ActionBoundingBox from './boundingBox/ActionBoundingBox.jsx';
import MaskBoundingBox from './boundingBox/MaskBoundingBox.jsx';
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

    sortedBbox(elements) {
        return elements.sort( (diffA, diffB) => {
            const dimA = diffA.dim
            const dimB = diffB.dim

            //calc sort order, want larger, containg rects to be rendered first
            //so subsequent smaller, contained rects have a higher paint order
            //and are clickable. Effectively sorting for z-index.
            //
            //NB: we sort a copy since Array.sort does so *in-place*, and reorders
            //the props.diffs order which affects renders

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
        })
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

        const elements = [].concat(...this.props.diffs, ...this.props.visibleActions)
        const maskBboxes = [];

        const Bboxes = this.sortedBbox(elements).map( elem => {

            const dim = elem.dim ? elem.dim :
                        (this.state.isControl ? elem.origDim : elem.newDim)

            if (elem.diffType) {

                /* build and collect matching diff rect masks */
                const mask = <MaskBoundingBox key={`mask-${elem.id}`}
                                              isControl={this.state.isControl}
                                              elem={elem}
                                              dim={dim}
                                              fill="black"/>;
                maskBboxes.push(mask)

                return <DiffBoundingBox key={elem.id}
                                        elem={elem}
                                        dim={dim}
                                        isControl={this.state.isControl}
                                        bboxHoverId={this.props.bboxHoverId}
                                        bboxHoverHandler={this.props.bboxHoverHandler}
                                        bboxClickHandler={this.props.diffBboxClickHandler}
                       />;
            }

            if (elem.actionType) {

                /* build and collect matching diff rect masks */
                const mask = <MaskBoundingBox key={`mask-{elem.id}`}
                                              isControl={this.state.isControl}
                                              elem={elem}
                                              dim={dim}
                                              fill="black"/>;
                maskBboxes.push(mask)

                return <ActionBoundingBox key={elem.id}
                                          elem={elem}
                                          dim={dim}
                                          isControl={this.state.isControl}
                                          bboxHoverId={this.props.bboxHoverId}
                                          bboxHoverHandler={this.props.bboxHoverHandler}
                                          bboxClickHandler={this.props.rerender}
                       />;
            }

        });

        const maskID = this.state.isControl ? 'c-svg-mask' : 'svg-mask';

        return(
            <svg style={svgStyle} className="svg"
                 viewBox={`0 0 ${this.state.imgWidth} ${this.state.imgHeight}`}
                 xmlns="http://www.w3.org/2000/svg">

                /* Mask */
                <defs>
                    <mask id={`${maskID}`}>

                        <rect x="0" y="0"
                              width={`${this.state.imgWidth}`}
                              height={`${this.state.imgHeight}`}
                              fill="white" />

                        { maskBboxes }
                    </mask>
                </defs>


                /* white, black toggle background here */
                <rect x="0" y="0"
                      width={`${this.state.imgWidth}`}
                      height={`${this.state.imgHeight}`}
                      fill="white"
                      fillOpacity="0.6"
                      mask={`url(#${maskID})`}/>

                {Bboxes}
            </svg>
        )
    }

  render() {

      let marginTop = '0px'
      if (this.props.shift) {
          marginTop = `${-this.props.shift}px`
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

      const obfuscateStyle = this.props.renderable.obfuscated ?
                             { wordBreak: 'break-all' } : {}

      return(
          <div className="column" style={wrapStyle}>

              <div className="mb-1">

                  <h4 className="mb-1">{this.props.label}</h4>

                  {this.props.renderable.renderedURL &&
                   <div className='is-size-6'
                        style={obfuscateStyle}
                        title={this.props.renderable.renderedTitle}>
                       {this.props.renderable.renderedURL.replace(/https?:\/\//, '')}
                   </div>
                  }

              </div>

              <RenderableScroll
                  scrollListener = {this.props.renderableScrollHandler}
                  shiftID={this.props.shiftID}
                  {...this.props}>

                  { this.drawSVGRects() }

              </RenderableScroll>

              <Img {...this.props} />
          </div>
      )
  }
}
