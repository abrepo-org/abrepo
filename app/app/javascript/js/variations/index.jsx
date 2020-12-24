import React from 'react';
import ReactDOM from 'react-dom';
import ActionContainer from './ActionContainer.jsx';
import DiffContainer from './DiffContainer.jsx';
import RenderableContainer from './RenderableContainer.jsx';


export default class Variation extends React.Component {

    constructor(props) {

        super(props);

        console.log('hi from Variation');
        console.log(this.props.data);

        this.state = {
            diffs: this.props.data.renderable.diffs,
            bboxVisible: true,
            diffHoverId: null
        }

    }

    //handlers:

    //action -> toggle renderable set
    //hide action for now, but likely needed

    //diff onhover -> bbox diffs color
    //diff click -> bbox scrollTo

    //bbox click -> diff scrollTo


    //diff_id 0 to "turn off?"
    diffHoverHandler(diff_id) {
        console.log("diffHoverHandler", diff_id);
        this.setState({
            diffHoverId: diff_id
        });
    }

    diffClickHandler(diff_id) {
        //setState clicked, toggle diff visible
        console.log("diffClickHandler", diff_id);
    }

    bboxClickHandler(diff_id) {
        console.log("bboxClickhandler", diff_id);
    }

    togglebboxClickHandler() {
        console.log("togglebboxClickHandler");
        this.setState({
            bboxVisible: !this.state.bboxVisible
        });

    }

    render() {

        if(!this.state.diffs) return <div></div>

        //active/base_renderable.screenshot

        return (
        <>
        <section class = "action">
            <ActionContainer {...this.props} />
        </section>

        <section className="renderableDiffs">

            {/*TODO: componentify*/}
            <div class="columns" >

                <div class="column is-full">
                    <h3> Renderables & Diff Controls </h3>
                    <p>icons, controls, etc. (e.g. text diff side vs interspersed) </p>
                    <p>place bboxClickhandler control here instead of img</p>
                    <p>TODO: make this a sticky nav scroll</p>
                    <button onClick={() => this.togglebboxClickHandler()}>Toggle bbox</button>
                </div>

            </div>

            <div className="columns">

                <DiffContainer diffs={this.state.diffs}
                               diffClickHandler={this.diffClickHandler}
                               diffHoverHandler={this.diffHoverHandler.bind(this)}
                               {...this.props} />


                <RenderableContainer diffs={this.state.diffs}
                                     renderable={this.props.data.renderable}
                                     bboxVisible={this.state.bboxVisible}
                                     diffHoverId={this.state.diffHoverId}
                                     bboxClickHandler={this.bboxClickHandler}
                                     {...this.props} />


                <RenderableContainer diffs={this.state.diffs}
                                     renderable={this.props.data.controlRenderable}
                                     bboxVisible={this.state.bboxVisible}
                                     diffHoverId={this.state.diffHoverId}
                                     bboxClickHandler={this.bboxClickHandler}
                                     {...this.props} />
            </div>
        </section>
        </>

        )

    }
}
