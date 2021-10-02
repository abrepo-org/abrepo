import React from 'react';
import ReactDOM from 'react-dom';
import ActionContainer from './ActionContainer.jsx';
import ControlsContainer from './ControlsContainer.jsx';
import DiffContainer from './DiffContainer.jsx';
import RenderableContainer from './RenderableContainer.jsx';
import ModalContainer from './diff/ModalContainer.jsx';

export default class Variation extends React.Component {

    constructor(props) {

        super(props);

        console.log('<Variation>', this.props.data);

        //set initial Action and Renderables
        const activeAction = this.props.data.actions[0];
        const activeRenderable = this.props.data.actionRenderables[activeAction.id].renderable;
        const activeControlRenderable = this.props.data.actionRenderables[activeAction.id].controlRenderable;
        const visibleActions = this.props.data.actionRenderables[activeAction.id].visibleActions;
        const isSingleView = window.innerWidth < 1215;

        this.state = {
            activeAction,
            activeRenderable,
            activeControlRenderable,
            visibleActions,
            diffs: activeRenderable.sortedDiffs,

            //Render action panel condition
            hasActions: this.props.data.actions.length > 1,

            //used for height of diff & renderable scrollbars, resizing
            renderableWidth: window.innerWidth,
            renderableHeight: window.innerHeight,
            isSingleView: false,

            bboxVisible: true,
            scrollBoxEnabled: false,
            resetShift: 0,
            bboxHoverId: null,

            isSingleView,
            activeView: isSingleView ? 1 : 0,

            diffVisible: true,

            modalDiff: null,

            shiftV: 0,  //shift Variation RenderableContainer
            shiftC: 0,  //shift Control RenderableContainer
            busy:false
        }


        //click diff or bbox to scroll
        this.diffPanelRef = React.createRef();
        this.renderablePanelRef = React.createRef();
    }

    //handlers:

    //action -> toggle renderable set
    //hide action for now, but likely needed

    //diff onhover -> bbox diffs color
    //diff click -> bbox scrollTo
    //diff_id 0 to "turn off?"

    actionSelectHandler(e) {
        console.log("CLICK actionSelectHandler", e.target);
        const actionID = e.target.value;
        this.rerender(actionID);
    }

    rerender(actionID) {
        console.log("rerender actionID:", actionID);
        const activeAction = this.props.data.actions.find( action => action.id == actionID);
        const activeRenderable = this.props.data.actionRenderables[activeAction.id].renderable;
        const activeControlRenderable = this.props.data.actionRenderables[activeAction.id]
                                            .controlRenderable;
        const visibleActions = this.props.data.actionRenderables[activeAction.id]
                                   .visibleActions;
        const diffs = activeRenderable.sortedDiffs;

        this.setState({
            activeAction, activeRenderable, activeControlRenderable, visibleActions, diffs
        })
    }

    //hover Bbox and DiffPanel diff
    bboxHoverHandler(elem_id) {
        this.setState({
            bboxHoverId: elem_id
        });
    }

    //DIFFPANEL diff click
    diffClickHandler(diffRef, location) {
        //setState clicked, toggle diff visible
        //ref are set in BoundingBox.jsx, Diff.jsx on componentDidMount
        //key for scrollBy is to aim at viewport midpoint - innerHeight/2
        console.log("diffClickHandler", diffRef, location);

        if (!location) return;

        /*
         * SHIFT offset
         * resets any off-screen shift of renderable container, while
         * maintaining the offset.
         *
         * A shift represents a Y value scroll.
         * shift > 0 is Y-value down, meaning the upper part of the
         * image scrolls off screen and won't be visible.
         *
         * Issue: when diffClick to scroll to bbox, position is off screen
         * so we calculate the offset and then re-shift everything to 0
         * to maintain alignment.
         */

        const offset = Math.abs(this.state.shiftV - this.state.shiftC);
        const shiftV = this.state.shiftV > this.state.shiftC ? 0 : -offset;
        const shiftC = this.state.shiftV > this.state.shiftC ? -offset : 0;

        this.setState({
            shiftV, shiftC
        });

        console.log("DIFFBB", this.state.shiftV, this.state.shiftC);

        const scaledContentHeight = this.getScaledHeight();

        const y = location.y;

        // displayed image can be too short for a scrollbar
        // (compared to window.innerHeight)
        //
        // in this case we scroll the global window down to the
        // y coord of the rect
        if (scaledContentHeight < window.innerHeight) {

            window.scrollTo({
                top: y,
                left: 0,
                behavior: 'smooth'
            });

        } else {

            this.renderablePanelRef.current.scrollBy({left:0,
                                                      top: y - window.innerHeight / 2,
                                                      behavior: "smooth"});
        }

        // Wiggle animation onClick to help identify diff location
        const addAnimation = ($bbox) => {

            $bbox.addEventListener('animationend', () => {
                $bbox.classList.toggle('shake');
            }, {once:true});

            $bbox.classList.toggle('shake');
        };

        const $newBbox = location.newDim && location.newDim.ref.current;
        if ($newBbox) addAnimation($newBbox);

        const $origBbox = location.origDim && location.origDim.ref.current;
        if ($origBbox) addAnimation($origBbox);

    }

    modalLaunchHandler(diff) {
        console.log("modalLaunchHandler", diff);
        this.setState({
            modalDiff: diff
        });
    }

    //DIFFBBOX elem: diff or action element (not bbox);
    diffBboxClickHandler(elem, rect) {
        console.log("diffBboxClickHandler", elem, rect);

        if(!rect && !elem) return;
        //modalDisplayElem: on mobile view; elems are hidden so bbox rect is null
        //for mobile, on bbox click we launch modal
        //otherwise skip modal and just scroll
        if(!rect) {
            this.setState({ modalElem: elem });
            return;
        }

        //ElemPanel desktop view
        const y = rect.y;

        this.diffPanelRef.current.scrollBy({left:0,
                                            top: y - window.innerHeight/2,
                                            behavior: "smooth"});
    }


    renderableScrollHandler(shiftID, deltaY) {
        console.log("rcScroll", shiftID, deltaY);

        //deltaY value is inconsistent across browsers, can only rely
        //on direction
        const normDeltaY = deltaY > 0 ? 1 : -1;
        const deltaYScrollFactor = 120;

        if (!this.state.busy) {
            setTimeout(() => {

                const shift = this.state[shiftID] + (normDeltaY * deltaYScrollFactor);

                this.setState({
                    [shiftID]: shift,
                    busy: false
                });

            }, 100);
        }

        this.setState({ busy: true});
    }


    resetScrollBoxHandler() {
        /* console.log("resetScrollBoxHandler", this.state.resetShift);
         * this.setState({resetShift: this.state.resetShift + 1})
         */
        this.setState({shiftV:0, shiftC:0});
    }

    //toggles for compare-single-double: {0,1,2}
    toggleActiveViewHandler(activeView) {
        console.log('toggleActiveViewHandler', activeView);
        this.setState({ activeView });
    }

    //toggle bbox visibility
    togglebboxClickHandler() {
        console.log("togglebboxClickHandler");
        this.setState({bboxVisible: !this.state.bboxVisible});
    }

    toggleScrollBoxHandler() {
        console.log("toggleScrollBoxHandler");
        this.setState({
            scrollBoxEnabled: !this.state.scrollBoxEnabled,
        });
    }

    toggleDiffVisibleHandler() {
        console.log("toggleDiffVisibleHandler", this.state.diffVisible);
        this.setState({diffVisible: !this.state.diffVisible})
    }

    windowResizeHandler() {

        //best compromise:
        //activeView: if it's now a singleView viewport but set to compare ->
        //set to default variation view (1). Otherwise use whatever activeView.
        //if its not singleView, leave it alone as it might be a user toggled state
        //(e.g. expanding)

        if (!this.state.busy) {
            setTimeout( () => {
                const isSingleView = window.innerWidth < 1215;
                const activeView =  isSingleView && this.state.activeView == 0 ?
                                    1 : this.state.activeView;

                this.setState({
                    renderableHeight: window.innerHeight,
                    renderableWidth: window.innerWidth,
                    isSingleView,
                    activeView,
                    busy: false
                })
            }, 350);
        }

        this.setState({busy:true});
    }

    getScaledHeight() {
        const $svgs = this.renderablePanelRef.current.querySelectorAll('svg');
        const svgDims = Array.from( $svgs )
                             .map( $svg => $svg.getBoundingClientRect().height );
        const scaledContentHeight = Math.max( ...svgDims );
        return scaledContentHeight;
    }

    componentDidMount() {
        window.addEventListener('resize', this.windowResizeHandler.bind(this));
    }

    componentWillUnmount() {
        window.removeEventListener('resize', this.windowResizeHandler.bind(this));
    }

    //TODO: compare with abannotate
    //fitlers diffs according to the single or double image view
    //compare both (0), variation-only or baseline-only
    filterDiffsActiveView(diffs) {

        if (this.state.activeView == 0) return diffs;

        return diffs.filter( diff => {

            //variation
            if(this.state.activeView == 1) {
                return (diff.newDim && diff.newDim.boundingBox)
            }

            //baseline
            if(this.state.activeView == 2) {
                return (diff.origDim && diff.origDim.boundingBox)
            }

            return false;
        });
    }

    //filters diffs for BoundingBox-component compatibile object
    //and selecting for control - newDim/origDim accordingly.
    filterRenderableDiffs(diffs, isControl) {
        const filtered = diffs.map(diff => {
            return isControl ?
                   {...diff, type: diff.diffType, dim: diff.origDim} :
                   {...diff, type: diff.diffType, dim: diff.newDim}
        })
        //console.log(isControl, filtered);
        return filtered;
    }

    /*
     * RENDER
     */
    render() {
        const diffWrapStyle = {
            overflowY: 'scroll',
            height: this.state.renderableHeight,
            padding: "0 .75rem"
        }

        console.log("WH", this.state.renderableWidth, this.state.renderableHeight);
        //toggles off scroll on mobile is-hidden-touch
        //1022 is mobile window width toggle
        const renderableContainerWrapStyle = this.state.renderableWidth > 1022 ? {
            overflowY: 'scroll',
            height: this.state.renderableHeight
            //listerner: on change resize / smaller devices what is this
        } : {}

        if(!this.state.diffs) return (<div></div>);

        const diffs = this.filterDiffsActiveView(this.state.diffs)
                          .sort( (diffA, diffB) => {
                              //
                              // sort DiffPanel diffs:
                              // basing on newDim for now (origDim also exists)
                              //
                              const dimA = diffA.newDim
                              const dimB = diffB.newDim

                              if (!dimA.boundingBox && !dimB.boundingBox) return 0;
                              if (dimA.boundingBox && !dimB.boundingBox) return -1;
                              if (!dimA.boundingBox && dimB.boundingBox) return 1;

                              //base return y ascending (small -> big)
                              return (dimA.boundingBox.rect.y == dimB.boundingBox.rect.y) ? 0 :
                                     dimA.boundingBox.rect.y > dimB.boundingBox.rect.y ? 1 : -1;

                          });

        return (
            <>
            {/* Action Container */}
            <section id="ActionControlPanel">
                {this.state.hasActions &&
                 <ActionContainer activeAction={this.state.activeAction}
                                  actionSelectHandler={this.actionSelectHandler.bind(this)}
                                  diffs={diffs}
                                  bboxHoverId={this.state.bboxHoverId}
                                  {...this.props} />
                }
                 <ControlsContainer togglebboxClickHandler={this.togglebboxClickHandler.bind(this)}
                                    bboxVisible={this.state.bboxVisible}
                                    toggleScrollBoxHandler={this.toggleScrollBoxHandler.bind(this)}
                                    scrollBoxEnabled={this.state.scrollBoxEnabled}
                                    resetScrollBoxHandler={this.resetScrollBoxHandler.bind(this)}

                                    isSingleView={this.state.isSingleView}
                                    activeView={this.state.activeView}
                                    toggleActiveViewHandler={this.toggleActiveViewHandler.bind(this)}

                                    toggleDiffVisibleHandler={this.toggleDiffVisibleHandler.bind(this)}
                                    diffVisible={this.state.diffVisible}
                                    {...this.props} />
                 <hr />
            </section>

             <section className="renderableDiffs">

                 <div className="columns">

                     <div className={`column is-3 is-hidden-touch ${this.state.diffVisible ? '' : 'is-hidden'}`}>

                         <div className="columns" >
                             <div className="column diffPanel"
                                  style={diffWrapStyle} ref={this.diffPanelRef}>

                                 <DiffContainer diffs={diffs}
                                                bboxHoverId={this.state.bboxHoverId}
                                                bboxHoverHandler={this.bboxHoverHandler.bind(this)}
                                                diffClickHandler={this.diffClickHandler.bind(this)}
                                                modalLaunchHandler={this.modalLaunchHandler.bind(this)}
                                                {...this.props}
                                 />

                             </div>
                         </div>
                     </div>

                     <div className="column">

                         <div className="columns renderableContainers"
                              style={renderableContainerWrapStyle}
                              ref={this.renderablePanelRef}>

                             <RenderableContainer label="Variation"
                                                  diffs={this.filterRenderableDiffs(diffs, false)}
                                                  visibleActions={this.state.visibleActions.active}
                                                  renderable={this.state.activeRenderable}
                                                  bboxVisible={this.state.bboxVisible}
                                                  scrollBoxEnabled={this.state.scrollBoxEnabled}

                                                  bboxHoverId={this.state.bboxHoverId}
                                                  bboxHoverHandler={this.bboxHoverHandler.bind(this)}
                                                  rerender={this.rerender.bind(this)}
                                                  diffBboxClickHandler={this.diffBboxClickHandler.bind(this)}
                                                  renderableScrollHandler={this.renderableScrollHandler.bind(this)}
                                                  shiftID="shiftV"
                                                  shift={this.state.shiftV}

                                                  isVisible={[0, 1].includes(this.state.activeView)}
                                                  {...this.props} />

                             <RenderableContainer label="Original"
                                                  diffs={this.filterRenderableDiffs(diffs, true)}
                                                  visibleActions={this.state.visibleActions.control}
                                                  renderable={this.state.activeControlRenderable}
                                                  bboxVisible={this.state.bboxVisible}
                                                  scrollBoxEnabled={this.state.scrollBoxEnabled}

                                                  bboxHoverId={this.state.bboxHoverId}
                                                  bboxHoverHandler={this.bboxHoverHandler.bind(this)}
                                                  rerender={this.rerender.bind(this)}
                                                  diffBboxClickHandler={this.diffBboxClickHandler.bind(this)}
                                                  renderableScrollHandler={this.renderableScrollHandler.bind(this)}
                                                  shiftID="shiftC"
                                                  shift={this.state.shiftC}

                                                  isVisible={[0, 2].includes(this.state.activeView)}
                                                  {...this.props} />


                             <ModalContainer title="Details"
                                             diff={this.state.modalDiff}
                                             modalLaunchHandler={ this.modalLaunchHandler.bind(this) }
                             />

                         </div>
                     </div>
                 </div>
             </section>
             </>

        )

    }
}
