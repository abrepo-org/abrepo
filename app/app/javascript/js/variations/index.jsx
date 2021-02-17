import React from 'react';
import ReactDOM from 'react-dom';
import ActionContainer from './ActionContainer.jsx';
import ControlsContainer from './ControlsContainer.jsx';
import DiffContainer from './DiffContainer.jsx';
import RenderableContainer from './RenderableContainer.jsx';
import MobileModal from './diff/MobileModal.jsx';

export default class Variation extends React.Component {

    constructor(props) {

        super(props);

        console.log('<Variation>', this.props.data);

        //set initial Action and Renderables
        const activeAction = this.props.data.actions[0];
        const activeRenderable = this.props.data.actionRenderables[activeAction.id].renderable;
        const activeControlRenderable = this.props.data.actionRenderables[activeAction.id].controlRenderable;
        const isSingleView = window.innerWidth < 1215;

        this.state = {
            activeAction,
            activeRenderable,
            activeControlRenderable,
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
            diffBboxHoverId: null,

            isSingleView,
            activeView: isSingleView ? 1 : 0,

            diffVisible: true,

            mobileModalContent: {diff: null},

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
        const actionID = e.target.value

        const activeAction = this.props.data.actions.find( action => action.id == actionID);
        const activeRenderable = this.props.data.actionRenderables[activeAction.id].renderable;
        const activeControlRenderable = this.props.data.actionRenderables[activeAction.id]
                                            .controlRenderable;
        const diffs = activeRenderable.sortedDiffs;

        this.setState({
            activeAction, activeRenderable, activeControlRenderable, diffs
        })
    }

    diffBboxHoverHandler(diff_id) {
        //console.log("diffBboxHoverHandler", diff_id);
        this.setState({
            diffBboxHoverId: diff_id
        });
    }

    diffClickHandler(currentRef, diff) {
        //setState clicked, toggle diff visible
        //bboxRef are set in BoundingBox.jsx, Diff.jsx on componentDidMount
        //key for scrollBy is to aim at viewport midpoint - innerHeight/2
        console.log("diffClickHandler", diff, currentRef);

        if (diff.newDim && diff.newDim.bboxRef.current) {
            const y = diff.newDim.bboxRef.current.getClientRects()[0].y
            const height = diff.newDim.bboxRef.current.getClientRects()[0].height
            this.renderablePanelRef.current.scrollBy({left:0,
                                                      top: y - window.innerHeight/2,
                                                      behavior: "smooth"});

        } else if (diff.origDim && diff.origDim.bboxRef.current) {
            const y = diff.origDim.bboxRef.current.getClientRects()[0].y
            const height = diff.origDim.bboxRef.current.getClientRects()[0].height
            this.renderablePanelRef.current.scrollBy({left:0,
                                                      top: y - window.innerHeight/2,
                                                      behavior: "smooth"});
        }
    }

    mobileModalCloseHandler() {
        console.log("mobileModalCloseHandler")

        this.setState({
            mobileModalContent: {diff: null}
        });
    }

    bboxClickHandler(currentRef, diff) {
        console.log("bboxClickhandler", this, diff.diffRef.current, currentRef);

        const rect = diff.diffRef.current.getClientRects()[0]
        if(!rect) {
            //if diffs are hidden rects are null
            //launch modal or tooltip or something
            this.setState({
                mobileModalContent: { diff }
            });
            return;
        }

        const y = rect.y
        const height = rect.height

        this.diffPanelRef.current.scrollBy({left:0,
                                            top: y - window.innerHeight/2,
                                            behavior: "smooth"});
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

    resetScrollBoxHandler() {
        console.log("resetScrollBoxHandler", this.state.resetShift);
        this.setState({resetShift: this.state.resetShift + 1})
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

    componentDidMount() {
        window.addEventListener('resize', this.windowResizeHandler.bind(this));
    }

    componentWillUnmount() {
        window.removeEventListener('resize', this.windowResizeHandler.bind(this));
    }

    //TODO: compare with abannotate
    filterDiffs(diffs) {

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

        if(!this.state.diffs) return <div></div>

        const diffs = this.filterDiffs(this.state.diffs);

        //active/base_renderable.screenshot

        return (
            <>
            {/* Action Container */}
            <section id="ActionControlPanel">
                {this.state.hasActions &&
                 <ActionContainer activeAction={this.state.activeAction}
                                  actionSelectHandler={this.actionSelectHandler.bind(this)}
                                  diffs={diffs}
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
                                                diffBboxHoverId={this.state.diffBboxHoverId}
                                                diffClickHandler={this.diffClickHandler.bind(this)}
                                                diffBboxHoverHandler={this.diffBboxHoverHandler.bind(this)}
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
                                                  diffs={diffs}
                                                  renderable={this.state.activeRenderable}
                                                  bboxVisible={this.state.bboxVisible}
                                                  scrollBoxEnabled={this.state.scrollBoxEnabled}
                                                  diffBboxHoverId={this.state.diffBboxHoverId}
                                                  diffBboxHoverHandler={this.diffBboxHoverHandler.bind(this)}
                                                  bboxClickHandler={this.bboxClickHandler.bind(this)}
                                                  resetShift={this.state.resetShift}

                                                  isVisible={[0, 1].includes(this.state.activeView)}
                                                  {...this.props} />

                             <RenderableContainer label="Original"
                                                  diffs={diffs}
                                                  renderable={this.state.activeControlRenderable}
                                                  bboxVisible={this.state.bboxVisible}
                                                  scrollBoxEnabled={this.state.scrollBoxEnabled}
                                                  diffBboxHoverId={this.state.diffBboxHoverId}
                                                  diffBboxHoverHandler={this.diffBboxHoverHandler.bind(this)}
                                                  bboxClickHandler={this.bboxClickHandler.bind(this)}
                                                  resetShift={this.state.resetShift}

                                                  isVisible={[0, 2].includes(this.state.activeView)}
                                                  {...this.props} />

                             <MobileModal diff={this.state.mobileModalContent.diff}
                                          mobileModalCloseHandler={this.mobileModalCloseHandler.bind(this)}
                             />
                         </div>
                     </div>
                 </div>
             </section>
             </>

        )

    }
}
