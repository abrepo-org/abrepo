import React from 'react';
import ReactDOM from 'react-dom';
import ActionContainer from './ActionContainer.jsx';
import ControlsContainer from './ControlsContainer.jsx';
import DiffContainer from './DiffContainer.jsx';
import RenderableContainer from './RenderableContainer.jsx';
import MobileModal from './MobileModal.jsx';

export default class Variation extends React.Component {

    constructor(props) {

        super(props);

        console.log('<Variation>', this.props.data);

        //set initial Action and Renderables
        const activeAction = this.props.data.actions[0];
        const activeRenderable = this.props.data.actionRenderables[activeAction.id].renderable;
        const activeControlRenderable = this.props.data.actionRenderables[activeAction.id].controlRenderable;

        this.state = {
            activeAction,
            activeRenderable,
            activeControlRenderable,
            diffs: activeRenderable.sortedDiffs,

            //Render action panel condition
            hasActions: this.props.data.actions.length > 1,

            //used for height of diff & renderable scrollbars
            renderableWidth: window.innerWidth,
            renderableHeight: window.innerHeight,
            bboxVisible: true,
            diffBboxHoverId: null,

            mobileModalIsOpen: false,
            mobileModalContent: {diff: null},

            shift: 0,
            busy: false
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
            mobileModalIsOpen: false,
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
                mobileModalIsOpen: true,
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

    togglebboxClickHandler() {
        console.log("togglebboxClickHandler");
        this.setState({
            bboxVisible: !this.state.bboxVisible
        });
    }

    windowResizeHandler() {
        this.setState({
            renderableHeight: window.innerHeight,
            renderableWidth: window.innerWidth
        })
    }

    renderableScrollHandler(deltaY) {
        console.log("rcScroll", deltaY);

        const deltaYScrollFactor = 9;

        if (!this.state.busy) {
            setTimeout(() => {

                this.setState({
                    shift: this.state.shift + (deltaY * deltaYScrollFactor),
                    busy: false
                });

            }, 100);
        }

        this.setState({ busy: true});
    }

    componentDidMount() {
        window.addEventListener('resize', this.windowResizeHandler.bind(this));
    }

    componentWillUnmount() {
        window.removeEventListener('resize', this.windowResizeHandler.bind(this));
    }

    render() {
        const diffWrapStyle = {
            overflowY: 'scroll',
            height: this.state.renderableHeight
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

        //active/base_renderable.screenshot

        return (
        <>

            {this.state.hasActions &&
             <>
             {/* Action Container */}
             <section id="ActionControlPanel">
                 <ActionContainer activeAction={this.state.activeAction}
                                  actionSelectHandler={this.actionSelectHandler.bind(this)}
                                  diffs={this.state.diffs}
                                  {...this.props} />

                 <ControlsContainer togglebboxClickHandler={this.togglebboxClickHandler.bind(this)}
                                    bboxVisible={this.state.bboxVisible}
                                    {...this.props} />
                 <hr />
             </section>

             </>
            }

             <section className="renderableDiffs">

                 <div className="columns">

                     <div className="column is-3 is-hidden-touch">

                         <div className="columns" >
                             <div className="column diffPanel"
                                  style={diffWrapStyle} ref={this.diffPanelRef}>
                                 <DiffContainer diffs={this.state.diffs}
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
                                                  diffs={this.state.diffs}
                                                  renderable={this.state.activeRenderable}
                                                  bboxVisible={this.state.bboxVisible}
                                                  diffBboxHoverId={this.state.diffBboxHoverId}
                                                  diffBboxHoverHandler={this.diffBboxHoverHandler.bind(this)}
                                                  bboxClickHandler={this.bboxClickHandler.bind(this)}
                                                  scrollListener = {this.renderableScrollHandler.bind(this)}
                                                  shift = {this.state.shift}
                                                  {...this.props} />

                             <RenderableContainer label="Original"
                                                  diffs={this.state.diffs}
                                                  renderable={this.state.activeControlRenderable}
                                                  bboxVisible={this.state.bboxVisible}
                                                  diffBboxHoverId={this.state.diffBboxHoverId}
                                                  diffBboxHoverHandler={this.diffBboxHoverHandler.bind(this)}
                                                  bboxClickHandler={this.bboxClickHandler.bind(this)}
                                                  scrollListener = {this.renderableScrollHandler.bind(this)}
                                                  {...this.props} />

                             <MobileModal isOpen={this.state.mobileModalIsOpen}
                                          content={this.state.mobileModalContent}
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
